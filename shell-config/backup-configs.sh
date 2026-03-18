#!/bin/bash
#
# Automated Config Backup Script
# Syncs zsh, tmux, and other shell configs to this repository
# Designed to be run via launchd (macOS) or cron
#

set -e

# ============================================================================
# Options
# ============================================================================

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# ============================================================================
# Configuration
# ============================================================================

# Repository location - UPDATE THIS to match your setup
REPO_DIR="${REPO_DIR:-$HOME/Documents/code/personal/personal-setup}"

# Config destination within the repo
CONFIG_DIR="$REPO_DIR/shell-config"

# Homebrew Brewfile destination within the repo
HOMEBREW_DIR="$REPO_DIR/homebrew-install"

# Log file location
LOG_FILE="$CONFIG_DIR/.backup.log"

# Files to backup: source and destination arrays (parallel arrays for bash 3.x compatibility)
# Add or remove files as needed - keep both arrays in sync
CONFIG_SOURCES=(
    "$HOME/.zshrc"
    "$HOME/.tmux.conf"
    "$HOME/.zprofile"
    "$HOME/.zshenv"
    "$HOME/.aliases"
    "$HOME/.functions"
    "$HOME/.gitconfig"
    "$HOME/.gitconfig-personal"
    "$HOME/.npmrc"
)

CONFIG_DESTS=(
    "zshrc"
    "tmux.conf"
    "zprofile"
    "zshenv"
    "aliases"
    "functions"
    "gitconfig"
    "gitconfig-personal"
    "npmrc"
)

# Optional: Additional config directories to backup
# These will be copied recursively
CONFIG_DIRS=(
    "$HOME/.config/nvim"
    "$HOME/.config/raycast/scripts"
    "$HOME/.config/ghostty"
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
    if [[ "$DRY_RUN" == true ]]; then
        log "Starting config backup (DRY RUN — no changes will be made)..."
    else
        log "Starting config backup..."
    fi

    # Ensure we're in the repo directory
    if [[ ! -d "$REPO_DIR/.git" ]]; then
        log_error "Repository not found at $REPO_DIR"
        log_error "Please update REPO_DIR in this script or set the REPO_DIR environment variable"
        exit 1
    fi

    cd "$REPO_DIR"

    # Ensure config directory exists
    if [[ "$DRY_RUN" != true ]]; then
        mkdir -p "$CONFIG_DIR"
    fi

    # Track if any files were updated
    local files_updated=0

    # Backup individual config files
    for i in "${!CONFIG_SOURCES[@]}"; do
        source_file="${CONFIG_SOURCES[$i]}"
        dest_name="${CONFIG_DESTS[$i]}"
        dest_file="$CONFIG_DIR/$dest_name"

        if [[ -f "$source_file" ]]; then
            # Check if file is different or doesn't exist in repo
            if [[ ! -f "$dest_file" ]] || ! diff -q "$source_file" "$dest_file" > /dev/null 2>&1; then
                if [[ "$DRY_RUN" == true ]]; then
                    log_success "Would update: $dest_name"
                else
                    cp "$source_file" "$dest_file"
                    log_success "Updated: $dest_name"
                fi
                files_updated=$((files_updated + 1))
            else
                log "No changes: $dest_name"
            fi
        else
            log_warning "Source not found: $source_file (skipping)"
        fi
    done

    # Regenerate Brewfile from currently installed packages
    if command -v brew &> /dev/null; then
        if [[ "$DRY_RUN" != true ]]; then
            mkdir -p "$HOMEBREW_DIR"
        fi
        local brewfile="$HOMEBREW_DIR/Brewfile"
        local brewfile_tmp="$HOMEBREW_DIR/Brewfile.tmp"

        if [[ "$DRY_RUN" == true ]]; then
            log "Would regenerate: Brewfile"
        else
            brew bundle dump --force --file="$brewfile_tmp" 2>/dev/null
            if [[ ! -f "$brewfile" ]] || ! diff -q "$brewfile_tmp" "$brewfile" > /dev/null 2>&1; then
                mv "$brewfile_tmp" "$brewfile"
                log_success "Updated: Brewfile"
                files_updated=$((files_updated + 1))
            else
                rm -f "$brewfile_tmp"
                log "No changes: Brewfile"
            fi
        fi
    else
        log_warning "brew not found, skipping Brewfile regeneration"
    fi

    # Backup config directories
    for source_dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$source_dir" ]]; then
            # Preserve relative path under ~/.config/ (e.g. raycast/scripts), else use basename
            if [[ "$source_dir" == "$HOME/.config/"* ]]; then
                dir_name="${source_dir#$HOME/.config/}"
            else
                dir_name=$(basename "$source_dir")
            fi
            dest_dir="$CONFIG_DIR/$dir_name"

            if [[ "$DRY_RUN" == true ]]; then
                log_success "Would sync directory: $dir_name"
                files_updated=$((files_updated + 1))
            else
                mkdir -p "$dest_dir"
                # Use rsync for directory sync (more efficient)
                if command -v rsync &> /dev/null; then
                    if rsync -a --checksum --delete "$source_dir/" "$dest_dir/" 2>/dev/null; then
                        log_success "Synced directory: $dir_name"
                        files_updated=$((files_updated + 1))
                    fi
                else
                    # Fallback to cp if rsync not available
                    rm -rf "$dest_dir"
                    cp -r "$source_dir" "$dest_dir"
                    log_success "Copied directory: $dir_name"
                    files_updated=$((files_updated + 1))
                fi
            fi
        fi
    done

    if [[ "$DRY_RUN" == true ]]; then
        if [[ "$files_updated" -gt 0 ]]; then
            log_success "Dry run complete: $files_updated file(s) would be updated"
        else
            log "Dry run complete: no changes detected"
        fi
        return
    fi

    # Check if there are any changes to commit
    if [[ -n $(git status --porcelain "$CONFIG_DIR" "$HOMEBREW_DIR") ]]; then
        log "Changes detected, committing..."

        # Stage changes
        git add "$CONFIG_DIR" "$HOMEBREW_DIR"

        # Create commit message with summary
        local changed_files=$(git diff --cached --name-only "$CONFIG_DIR" "$HOMEBREW_DIR" | xargs -I {} basename {} | tr '\n' ', ' | sed 's/,$//')
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
