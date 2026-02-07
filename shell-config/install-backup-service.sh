#!/bin/bash
#
# Install/Uninstall the config backup launchd service
# Usage: ./install-backup-service.sh [install|uninstall|status]
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLIST_NAME="com.personal-setup.config-backup.plist"
PLIST_SOURCE="$SCRIPT_DIR/$PLIST_NAME"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_NAME"
SERVICE_NAME="com.personal-setup.config-backup"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  Config Backup Service Installer${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo
}

get_repo_path() {
    # Detect the repo path from the script location
    echo "$(dirname "$SCRIPT_DIR")"
}

install_service() {
    print_header
    echo -e "${YELLOW}Installing backup service...${NC}"
    echo

    # Get the actual repo path
    local repo_path=$(get_repo_path)
    local username=$(whoami)

    # Check if plist source exists
    if [[ ! -f "$PLIST_SOURCE" ]]; then
        echo -e "${RED}Error: Plist file not found at $PLIST_SOURCE${NC}"
        exit 1
    fi

    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$HOME/Library/LaunchAgents"

    # Unload existing service if running
    if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
        echo "Unloading existing service..."
        launchctl unload "$PLIST_DEST" 2>/dev/null || true
    fi

    # Copy and customize plist
    echo "Configuring service for your system..."
    sed -e "s|\$HOME|$HOME|g" \
        -e "s|YOUR_USERNAME|$username|g" \
        -e "s|/Users/YOUR_USERNAME/Documents/code/personal/personal-setup|$repo_path|g" \
        "$PLIST_SOURCE" > "$PLIST_DEST"

    # Validate plist syntax
    if ! plutil -lint "$PLIST_DEST" > /dev/null 2>&1; then
        echo -e "${RED}Error: Generated plist has syntax errors${NC}"
        rm "$PLIST_DEST"
        exit 1
    fi

    # Load the service
    echo "Loading service..."
    launchctl load "$PLIST_DEST"

    echo
    echo -e "${GREEN}✓ Service installed successfully!${NC}"
    echo
    echo "The backup will run:"
    echo "  - Immediately when the service starts"
    echo "  - Every 6 hours thereafter"
    echo
    echo "Log files:"
    echo "  - stdout: /tmp/config-backup.stdout.log"
    echo "  - stderr: /tmp/config-backup.stderr.log"
    echo "  - backup: $repo_path/shell-config/.backup.log"
    echo
    echo "To check status: $0 status"
    echo "To uninstall:    $0 uninstall"
}

uninstall_service() {
    print_header
    echo -e "${YELLOW}Uninstalling backup service...${NC}"
    echo

    if [[ -f "$PLIST_DEST" ]]; then
        # Unload the service
        echo "Unloading service..."
        launchctl unload "$PLIST_DEST" 2>/dev/null || true

        # Remove the plist
        echo "Removing plist..."
        rm "$PLIST_DEST"

        echo
        echo -e "${GREEN}✓ Service uninstalled successfully!${NC}"
    else
        echo -e "${YELLOW}Service is not installed.${NC}"
    fi
}

show_status() {
    print_header
    echo -e "${YELLOW}Service Status${NC}"
    echo

    if [[ -f "$PLIST_DEST" ]]; then
        echo -e "Installed: ${GREEN}Yes${NC}"
        echo "Plist location: $PLIST_DEST"
        echo

        if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
            echo -e "Running: ${GREEN}Yes${NC}"
            echo
            echo "Service details:"
            launchctl list "$SERVICE_NAME" 2>/dev/null || echo "  (unable to get details)"
        else
            echo -e "Running: ${RED}No${NC}"
            echo
            echo "To start the service:"
            echo "  launchctl load $PLIST_DEST"
        fi
    else
        echo -e "Installed: ${RED}No${NC}"
        echo
        echo "To install the service:"
        echo "  $0 install"
    fi

    echo
    echo "Recent log entries:"
    echo "---"
    local repo_path=$(get_repo_path)
    if [[ -f "$repo_path/shell-config/.backup.log" ]]; then
        tail -10 "$repo_path/shell-config/.backup.log" 2>/dev/null || echo "(no logs yet)"
    else
        echo "(no logs yet)"
    fi
}

run_now() {
    print_header
    echo -e "${YELLOW}Running backup now...${NC}"
    echo

    local repo_path=$(get_repo_path)
    REPO_DIR="$repo_path" "$SCRIPT_DIR/backup-configs.sh"
}

show_help() {
    print_header
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  install    Install the launchd service (runs every 6 hours)"
    echo "  uninstall  Remove the launchd service"
    echo "  status     Show service status and recent logs"
    echo "  run        Run the backup immediately (without installing service)"
    echo "  help       Show this help message"
    echo
    echo "Examples:"
    echo "  $0 install     # Install and start the service"
    echo "  $0 status      # Check if service is running"
    echo "  $0 run         # Run backup manually"
}

# Main
case "${1:-help}" in
    install)
        install_service
        ;;
    uninstall)
        uninstall_service
        ;;
    status)
        show_status
        ;;
    run)
        run_now
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo
        show_help
        exit 1
        ;;
esac
