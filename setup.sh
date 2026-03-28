#!/bin/bash
#
# Personal Setup Bootstrap Script
# Sets up a fresh Mac with all tools, configs, and preferences
#
# Usage (fresh machine — pipe from GitHub):
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kevinreber/personal-setup/main/setup.sh)"
#
# Usage (repo already cloned):
#   ./setup.sh
#

set -e

REPO_URL="https://github.com/kevinreber/personal-setup.git"
DEFAULT_REPO_DIR="$HOME/Projects/personal-setup"

# If running from inside the repo, use that path; otherwise use the default
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
if [[ -f "$SCRIPT_DIR/homebrew-install/Brewfile" ]]; then
    REPO_DIR="$SCRIPT_DIR"
else
    REPO_DIR="$DEFAULT_REPO_DIR"
fi

# ============================================================================
# Colors
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ============================================================================
# Helpers
# ============================================================================

print_header() {
    echo
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
}

log()         { echo -e "${BLUE}  →${NC} $1"; }
log_success() { echo -e "${GREEN}  ✓${NC} $1"; }
log_warning() { echo -e "${YELLOW}  !${NC} $1"; }
log_error()   { echo -e "${RED}  ✗${NC} $1" >&2; }
log_skip()    { echo -e "  ${YELLOW}(skip)${NC} $1"; }

confirm() {
    local prompt="$1"
    local default="${2:-y}"
    local options
    if [[ "$default" == "y" ]]; then options="[Y/n]"; else options="[y/N]"; fi
    echo -en "${YELLOW}  ?${NC} $prompt $options: "
    read -r response
    response="${response:-$default}"
    [[ "$response" =~ ^[Yy]$ ]]
}

# ============================================================================
# Step 1 — Xcode Command Line Tools
# ============================================================================

install_xcode_clt() {
    print_header "Step 1 — Xcode Command Line Tools"

    if xcode-select -p &>/dev/null; then
        log_success "Xcode Command Line Tools already installed"
        return
    fi

    log "Installing Xcode Command Line Tools..."
    log_warning "A dialog will appear — click 'Install' and wait for it to finish."
    xcode-select --install 2>/dev/null || true

    log "Waiting for Xcode CLT installation to complete..."
    local max_wait=600  # 10 minutes
    local waited=0
    until xcode-select -p &>/dev/null; do
        sleep 5
        waited=$((waited + 5))
        if [[ "$waited" -ge "$max_wait" ]]; then
            log_error "Timed out waiting for Xcode CLT installation (${max_wait}s)"
            log_error "Install manually: xcode-select --install"
            exit 1
        fi
    done
    log_success "Xcode Command Line Tools installed"
}

# ============================================================================
# Step 2 — Homebrew
# ============================================================================

install_homebrew() {
    print_header "Step 2 — Homebrew"

    if command -v brew &>/dev/null; then
        log_success "Homebrew already installed ($(brew --version | head -1))"
        log "Updating Homebrew..."
        brew update --quiet
        log_success "Homebrew updated"
        return
    fi

    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for the rest of this script (Apple Silicon path)
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    log_success "Homebrew installed"
}

# ============================================================================
# Step 3 — Clone or update the repo
# ============================================================================

setup_repo() {
    print_header "Step 3 — personal-setup Repository"

    if [[ -d "$REPO_DIR/.git" ]]; then
        log_success "Repo already exists at $REPO_DIR"
        log "Pulling latest changes..."
        git -C "$REPO_DIR" pull --quiet
        log_success "Repo up to date"
        return
    fi

    log "Cloning $REPO_URL → $REPO_DIR"
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone "$REPO_URL" "$REPO_DIR"
    log_success "Repo cloned to $REPO_DIR"
}

# ============================================================================
# Step 4 — Homebrew packages (Brewfile)
# ============================================================================

install_brew_packages() {
    print_header "Step 4 — Homebrew Packages"

    local brewfile="$REPO_DIR/homebrew-install/Brewfile"
    if [[ ! -f "$brewfile" ]]; then
        log_warning "Brewfile not found at $brewfile — skipping"
        return
    fi

    log "Installing packages from Brewfile..."
    log_warning "This may take a while on a fresh machine."
    echo

    # --no-upgrade skips upgrading already-installed packages
    # (just ensures everything in the Brewfile exists)
    brew bundle install --file="$brewfile"
    log_success "All Brewfile packages installed"
}

# ============================================================================
# Step 5 — Oh My Zsh + plugins
# ============================================================================

install_oh_my_zsh() {
    print_header "Step 5 — Oh My Zsh & Plugins"

    # Install Oh My Zsh (check for key file to handle partial installs)
    if [[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        log_success "Oh My Zsh already installed"
    else
        log "Installing Oh My Zsh..."
        # RUNZSH=no prevents it from launching a new zsh session
        # KEEP_ZSHRC=yes prevents it from overwriting our backed-up .zshrc
        RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        log_success "Oh My Zsh installed"
    fi

    # ZSH_CUSTOM is not set in bash context, so hardcode the default path
    local custom_dir="$HOME/.oh-my-zsh/custom"

    # Install zsh-syntax-highlighting (check .git to handle partial clones)
    if [[ -d "$custom_dir/plugins/zsh-syntax-highlighting/.git" ]]; then
        log_success "zsh-syntax-highlighting already installed"
    else
        log "Installing zsh-syntax-highlighting..."
        git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_dir/plugins/zsh-syntax-highlighting"
        log_success "zsh-syntax-highlighting installed"
    fi

    # Install zsh-autosuggestions (check .git to handle partial clones)
    if [[ -d "$custom_dir/plugins/zsh-autosuggestions/.git" ]]; then
        log_success "zsh-autosuggestions already installed"
    else
        log "Installing zsh-autosuggestions..."
        git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git "$custom_dir/plugins/zsh-autosuggestions"
        log_success "zsh-autosuggestions installed"
    fi
}

# ============================================================================
# Step 6 — Restore shell configs
# ============================================================================

restore_shell_configs() {
    print_header "Step 6 — Shell Configs"

    local config_dir="$REPO_DIR/shell-config"

    # Parallel arrays mirroring backup-configs.sh
    local dests=(
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
    local targets=(
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

    local any_restored=0

    for i in "${!dests[@]}"; do
        local src="$config_dir/${dests[$i]}"
        local dest="${targets[$i]}"

        if [[ ! -f "$src" ]]; then
            log_skip "${dests[$i]} (not in repo)"
            continue
        fi

        if [[ -f "$dest" ]]; then
            if diff -q "$src" "$dest" &>/dev/null; then
                log "No changes: ${dests[$i]}"
                continue
            fi

            if confirm "Overwrite existing $dest with backed-up version?"; then
                local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
                cp "$dest" "$backup"
                log "  Existing file backed up to $backup"
                cp "$src" "$dest"
                log_success "Restored: $dest"
                any_restored=$((any_restored + 1))
            else
                log_skip "$dest (kept existing)"
            fi
        else
            cp "$src" "$dest"
            log_success "Restored: $dest"
            any_restored=$((any_restored + 1))
        fi
    done

    # Restore config directories
    local dir_sources=("nvim" "raycast/scripts" "ghostty")
    local dir_targets=("$HOME/.config/nvim" "$HOME/.config/raycast/scripts" "$HOME/.config/ghostty")

    for i in "${!dir_sources[@]}"; do
        local src="$config_dir/${dir_sources[$i]}"
        local dest="${dir_targets[$i]}"

        if [[ ! -d "$src" ]]; then
            log_skip "${dir_sources[$i]}/ (not in repo)"
            continue
        fi

        if [[ -d "$dest" ]]; then
            if confirm "Overwrite existing $dest with backed-up version?"; then
                local backup="${dest}.backup.$(date +%Y%m%d_%H%M%S)"
                cp -r "$dest" "$backup"
                log "  Existing directory backed up to $backup"
                rm -rf "$dest"
                cp -r "$src" "$dest"
                log_success "Restored: $dest"
                any_restored=$((any_restored + 1))
            else
                log_skip "$dest (kept existing)"
            fi
        else
            mkdir -p "$(dirname "$dest")"
            cp -r "$src" "$dest"
            log_success "Restored: $dest"
            any_restored=$((any_restored + 1))
        fi
    done

    if [[ "$any_restored" -gt 0 ]]; then
        log_warning "Shell configs restored. Restart your terminal (or run 'source ~/.zshrc') to apply."
    fi
}

# ============================================================================
# Step 7 — Git config & SSH keys
# ============================================================================

setup_git_config() {
    print_header "Step 7 — Git Configuration"

    local git_setup="$REPO_DIR/github-ssh-setup/setup-git-config.sh"
    if [[ ! -f "$git_setup" ]]; then
        log_warning "Git config setup script not found — skipping"
        return
    fi

    if confirm "Run git/SSH config setup script?"; then
        bash "$git_setup"
    else
        log_skip "Git config setup"
        log "  You can run it later: $git_setup"
    fi
}

# ============================================================================
# Step 8 — Auto-backup launchd service
# ============================================================================

check_ssh_auth() {
    log "Checking GitHub SSH authentication..."
    local ssh_output
    ssh_output=$(ssh -T -o ConnectTimeout=5 -o BatchMode=yes git@github.com 2>&1 || true)

    if echo "$ssh_output" | grep -q "successfully authenticated"; then
        log_success "GitHub SSH auth working"
        return 0
    else
        log_warning "GitHub SSH auth failed — the backup service won't be able to push."
        log_warning "Output: $ssh_output"
        log         "  Fix: generate/add your SSH key, then run: ssh -T git@github.com"
        return 1
    fi
}

install_backup_service() {
    print_header "Step 8 — Auto-Backup Service"

    local service_script="$REPO_DIR/shell-config/install-backup-service.sh"
    if [[ ! -f "$service_script" ]]; then
        log_warning "Backup service installer not found — skipping"
        return
    fi

    if launchctl list 2>/dev/null | grep -q "com.personal-setup.config-backup"; then
        log_success "Backup service already installed and running"
        return
    fi

    # Warn if SSH auth isn't working — the service needs it to push
    if ! check_ssh_auth; then
        if ! confirm "SSH auth isn't set up yet. Install the backup service anyway?"; then
            log_skip "Backup service (install it later once SSH is working)"
            log "  Run: $service_script install"
            return
        fi
    fi

    if confirm "Install auto-backup launchd service? (backs up shell configs every 6 hours)"; then
        bash "$service_script" install
    else
        log_skip "Backup service"
        log "  You can install it later: $service_script install"
    fi
}

# ============================================================================
# Summary
# ============================================================================

print_summary() {
    print_header "Setup Complete!"

    echo -e "  ${BOLD}What was set up:${NC}"
    echo "    • Xcode Command Line Tools"
    echo "    • Homebrew + all packages from Brewfile"
    echo "    • personal-setup repo at $REPO_DIR"
    echo "    • Oh My Zsh + plugins (syntax-highlighting, autosuggestions)"
    echo "    • Shell configs (zshrc, tmux, zprofile, etc.)"
    echo "    • Git configuration"
    echo "    • Auto-backup launchd service"
    echo
    echo -e "  ${BOLD}Next steps:${NC}"
    echo "    1. Restart your terminal to apply shell configs"
    echo "    2. Verify SSH keys are set up:  ssh -T git@github.com"
    echo "    3. Check backup service status: $REPO_DIR/shell-config/install-backup-service.sh status"
    echo
}

# ============================================================================
# Main
# ============================================================================

main() {
    clear
    echo
    echo -e "${BOLD}${BLUE}  Personal Mac Setup${NC}"
    echo -e "  Setting up your development environment from scratch."
    echo

    install_xcode_clt
    install_homebrew
    setup_repo
    install_brew_packages
    install_oh_my_zsh
    restore_shell_configs
    setup_git_config
    install_backup_service
    print_summary
}

main "$@"
