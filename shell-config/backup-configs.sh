#!/bin/bash
#
# Automated Config Backup Script
# Syncs zsh, tmux, and other shell configs to this repository
# Designed to be run via launchd (macOS) or cron
#

set -e

# ============================================================================
# Configuration
# ============================================================================

# Repository location - UPDATE THIS to match your setup
REPO_DIR="${REPO_DIR:-$HOME/Documents/code/personal/personal-setup}"

# Config destination within the repo
CONFIG_DIR="$REPO_DIR/shell-config"

# Log file location
LOG_FILE="$CONFIG_DIR/.backup.log"

# Files to backup (source -> destination name)
# Add or remove files as needed
declare -A CONFIG_FILES=(
    ["$HOME/.zshrc"]="zshrc"
    ["$HOME/.tmux.conf"]="tmux.conf"
    ["$HOME/.zprofile"]="zprofile"
    ["$HOME/.zshenv"]="zshenv"
    ["$HOME/.aliases"]="aliases"
    ["$HOME/.functions"]="functions"
)

# Optional: Additional config directories to backup
# These will be copied recursively
declare -a CONFIG_DIRS=(
    # "$HOME/.config/some-tool"
)

# ============================================================================
# Helper Functions
# ============================================================================

# Colors for output (disabled if not interactive)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

log() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${BLUE}[$timestamp]${NC} $1"
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

log_success() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${GREEN}[$timestamp] ✓${NC} $1"
    echo "[$timestamp] ✓ $1" >> "$LOG_FILE"
}

log_warning() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${YELLOW}[$timestamp] !${NC} $1"
    echo "[$timestamp] ! $1" >> "$LOG_FILE"
}

log_error() {
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${RED}[$timestamp] ✗${NC} $1" >&2
    echo "[$timestamp] ✗ $1" >> "$LOG_FILE"
}

# ============================================================================
# Main Script
# ============================================================================

main() {
    log "Starting config backup..."

    # Ensure we're in the repo directory
    if [[ ! -d "$REPO_DIR/.git" ]]; then
        log_error "Repository not found at $REPO_DIR"
        log_error "Please update REPO_DIR in this script or set the REPO_DIR environment variable"
        exit 1
    fi

    cd "$REPO_DIR"

    # Ensure config directory exists
    mkdir -p "$CONFIG_DIR"

    # Track if any files were updated
    local files_updated=0

    # Backup individual config files
    for source_file in "${!CONFIG_FILES[@]}"; do
        dest_name="${CONFIG_FILES[$source_file]}"
        dest_file="$CONFIG_DIR/$dest_name"

        if [[ -f "$source_file" ]]; then
            # Check if file is different or doesn't exist in repo
            if [[ ! -f "$dest_file" ]] || ! diff -q "$source_file" "$dest_file" > /dev/null 2>&1; then
                cp "$source_file" "$dest_file"
                log_success "Updated: $dest_name"
                ((files_updated++))
            else
                log "No changes: $dest_name"
            fi
        else
            log_warning "Source not found: $source_file (skipping)"
        fi
    done

    # Backup config directories
    for source_dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$source_dir" ]]; then
            dir_name=$(basename "$source_dir")
            dest_dir="$CONFIG_DIR/$dir_name"

            # Use rsync for directory sync (more efficient)
            if command -v rsync &> /dev/null; then
                if rsync -a --checksum --delete "$source_dir/" "$dest_dir/" 2>/dev/null; then
                    log_success "Synced directory: $dir_name"
                    ((files_updated++))
                fi
            else
                # Fallback to cp if rsync not available
                rm -rf "$dest_dir"
                cp -r "$source_dir" "$dest_dir"
                log_success "Copied directory: $dir_name"
                ((files_updated++))
            fi
        fi
    done

    # Check if there are any changes to commit
    if [[ -n $(git status --porcelain "$CONFIG_DIR") ]]; then
        log "Changes detected, committing..."

        # Stage changes
        git add "$CONFIG_DIR"

        # Create commit message with summary
        local changed_files=$(git diff --cached --name-only "$CONFIG_DIR" | xargs -I {} basename {} | tr '\n' ', ' | sed 's/,$//')
        local commit_msg="auto-backup: sync shell configs

Updated files: $changed_files
Backup timestamp: $(date "+%Y-%m-%d %H:%M:%S")"

        git commit -m "$commit_msg"
        log_success "Committed changes"

        # Push to remote
        log "Pushing to remote..."
        if git push 2>&1; then
            log_success "Pushed to remote successfully"
        else
            log_error "Failed to push to remote. Will retry on next run."
            exit 1
        fi
    else
        log "No changes to commit"
    fi

    log_success "Backup complete!"
}

# Run main function
main "$@"
