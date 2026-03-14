#!/bin/bash

################################################################################
# Git Configuration Setup Script
#
# Sets up Git configuration with SSH keys. Supports two modes:
#
#   ./setup-git-config.sh          # Personal SSH only (default)
#   ./setup-git-config.sh --work   # Personal + work SSH keys
#
# Default mode uses personal email/SSH key as the global default.
#
# With --work, uses includeIf to switch SSH keys by directory:
# - Personal projects (~/Documents/code/personal/): kevinreber1@gmail.com
# - Work projects (all others): kreber@linkedin.com
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse flags
INCLUDE_WORK=false
for arg in "$@"; do
    case "$arg" in
        --work) INCLUDE_WORK=true ;;
        --help|-h)
            echo "Usage: $0 [--work]"
            echo ""
            echo "  (no flags)  Set up personal SSH key only (default)"
            echo "  --work      Also set up work SSH key with directory-based switching"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Usage: $0 [--work]"
            exit 1
            ;;
    esac
done

# Configuration — override any of these with environment variables before running
PERSONAL_EMAIL="${PERSONAL_EMAIL:-kevinreber1@gmail.com}"
WORK_EMAIL="${WORK_EMAIL:-kreber@linkedin.com}"
USER_NAME="${USER_NAME:-Kevin Reber}"
PERSONAL_SSH_KEY="${PERSONAL_SSH_KEY:-$HOME/.ssh/id_ed25519_kevinreber_personal}"
WORK_SSH_KEY="${WORK_SSH_KEY:-$HOME/.ssh/kreber_at_linkedin.com_ssh_key}"
PERSONAL_DIR="${PERSONAL_DIR:-$HOME/Documents/code/personal/}"

print_header() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Backup existing file
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$file" "$backup"
        print_success "Backed up existing file to: $backup"
    fi
}

# Check if SSH key exists
check_ssh_key() {
    local key_path="${1/#\~/$HOME}"
    if [ ! -f "$key_path" ]; then
        print_error "SSH key not found: $key_path"
        return 1
    fi
    print_success "SSH key found: $key_path"
    return 0
}

# Check SSH key permissions
check_ssh_permissions() {
    local key_path="${1/#\~/$HOME}"
    local perms=$(stat -f "%Lp" "$key_path" 2>/dev/null || echo "000")

    if [ "$perms" != "600" ]; then
        print_warning "SSH key has incorrect permissions: $perms (should be 600)"
        print_info "Fixing permissions..."
        chmod 600 "$key_path"
        print_success "Permissions fixed: $key_path"
    else
        print_success "SSH key permissions correct: $key_path"
    fi
}

# Main setup function
setup_git_configs() {
    print_header "Git Configuration Setup"

    if [[ "$INCLUDE_WORK" == true ]]; then
        print_info "Mode: personal + work"
    else
        print_info "Mode: personal-only (no work SSH config)"
    fi

    # Step 1: Check SSH keys
    print_info "Checking SSH keys..."

    local personal_key_exists=true
    local work_key_exists=true

    if ! check_ssh_key "$PERSONAL_SSH_KEY"; then
        personal_key_exists=false
        print_warning "Personal SSH key not found. You'll need to generate or copy it."
    else
        check_ssh_permissions "$PERSONAL_SSH_KEY"
    fi

    if [[ "$INCLUDE_WORK" == true ]]; then
        if ! check_ssh_key "$WORK_SSH_KEY"; then
            work_key_exists=false
            print_warning "Work SSH key not found. You'll need to generate or copy it."
        else
            check_ssh_permissions "$WORK_SSH_KEY"
        fi
    fi

    if [[ "$INCLUDE_WORK" != true ]]; then
        # Personal-only: create a single .gitconfig with personal as default
        print_info "\nCreating ~/.gitconfig (personal-only)..."

        if [ -f "$HOME/.gitconfig" ]; then
            backup_file "$HOME/.gitconfig"
        fi

        cat > "$HOME/.gitconfig" << EOF
[user]
	name = $USER_NAME
	email = $PERSONAL_EMAIL

[core]
	sshCommand = "ssh -i $PERSONAL_SSH_KEY -o IdentitiesOnly=yes"

[http]
	postBuffer = 524288000

[push]
	default = current
	autosetupremote = true

[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true

[credential]
	helper = store

[credential "https://github.com"]
	helper =
	helper = !/opt/homebrew/bin/gh auth git-credential

[credential "https://gist.github.com"]
	helper =
	helper = !/opt/homebrew/bin/gh auth git-credential
EOF

        print_success "Created ~/.gitconfig"
    else
        # Full mode: create .gitconfig-personal + .gitconfig with includeIf

        # Step 2: Create ~/.gitconfig-personal
        print_info "\nCreating ~/.gitconfig-personal..."
        backup_file "$HOME/.gitconfig-personal"

        cat > "$HOME/.gitconfig-personal" << EOF
# Personal Git configuration
# This config is automatically loaded for repositories under $PERSONAL_DIR

[user]
	name = $USER_NAME
	email = $PERSONAL_EMAIL

[core]
	sshCommand = "ssh -i $PERSONAL_SSH_KEY -o IdentitiesOnly=yes"
EOF

        print_success "Created ~/.gitconfig-personal"

        # Step 3: Update or create ~/.gitconfig
        print_info "\nUpdating ~/.gitconfig..."

        if [ -f "$HOME/.gitconfig" ]; then
            # Check if conditional include already exists
            if grep -q "includeIf.*gitdir:${PERSONAL_DIR}" "$HOME/.gitconfig"; then
                print_info "Conditional include already exists in ~/.gitconfig"
            else
                print_info "Adding conditional include to existing ~/.gitconfig"
                backup_file "$HOME/.gitconfig"

                # Add conditional include if not present
                if ! grep -q "^\[core\]" "$HOME/.gitconfig"; then
                    # Add core section with sshCommand
                    sed -i '' '/^\[user\]/a\
[core]\
	sshCommand = "ssh -i '"$WORK_SSH_KEY"' -o IdentitiesOnly=yes"
' "$HOME/.gitconfig"
                elif ! grep -q "sshCommand" "$HOME/.gitconfig"; then
                    # Add sshCommand to existing core section
                    sed -i '' '/^\[core\]/a\
	sshCommand = "ssh -i '"$WORK_SSH_KEY"' -o IdentitiesOnly=yes"
' "$HOME/.gitconfig"
                fi

                # Add conditional include at the end
                echo "" >> "$HOME/.gitconfig"
                echo "# Conditional includes - use personal config for personal projects" >> "$HOME/.gitconfig"
                echo "[includeIf \"gitdir:${PERSONAL_DIR}\"]" >> "$HOME/.gitconfig"
                echo "	path = ~/.gitconfig-personal" >> "$HOME/.gitconfig"

                print_success "Updated ~/.gitconfig with conditional include"
            fi
        else
            # Create new .gitconfig
            cat > "$HOME/.gitconfig" << EOF
[user]
	name = $USER_NAME
	email = $WORK_EMAIL

[core]
	sshCommand = "ssh -i $WORK_SSH_KEY -o IdentitiesOnly=yes"

[http]
	postBuffer = 524288000

[push]
	default = current
	autosetupremote = true

[filter "lfs"]
	clean = git-lfs clean -- %f
	smudge = git-lfs smudge -- %f
	process = git-lfs filter-process
	required = true

[credential]
	helper = store

[credential "https://github.com"]
	helper =
	helper = !/opt/homebrew/bin/gh auth git-credential

[credential "https://gist.github.com"]
	helper =
	helper = !/opt/homebrew/bin/gh auth git-credential

# Conditional includes - use personal config for personal projects
[includeIf "gitdir:${PERSONAL_DIR}"]
	path = ~/.gitconfig-personal
EOF

            print_success "Created ~/.gitconfig"
        fi
    fi

    # Step 4: Verify setup
    print_header "Verification"

    print_info "Testing configuration..."

    if [[ "$INCLUDE_WORK" == true ]]; then
        # Test in a work directory (parent of PERSONAL_DIR)
        local work_dir
        work_dir="$(dirname "$PERSONAL_DIR")"
        if [ -d "$work_dir" ]; then
            cd "$work_dir"
            local work_email=$(git config user.email)
            local work_ssh=$(git config core.sshCommand)

            if [ "$work_email" = "$WORK_EMAIL" ]; then
                print_success "Work directory config correct: $work_email"
            else
                print_error "Work directory config incorrect: $work_email (expected: $WORK_EMAIL)"
            fi

            if [[ "$work_ssh" == *"$(basename "$WORK_SSH_KEY")"* ]]; then
                print_success "Work SSH key config correct"
            else
                print_warning "Work SSH key config: $work_ssh"
            fi
        fi
    fi

    # Test in a personal directory (if exists)
    if [ -d "$PERSONAL_DIR" ]; then
        cd "$PERSONAL_DIR"
        local personal_email=$(git config user.email)
        local personal_ssh=$(git config core.sshCommand)

        if [ "$personal_email" = "$PERSONAL_EMAIL" ]; then
            print_success "Personal directory config correct: $personal_email"
        else
            print_error "Personal directory config incorrect: $personal_email (expected: $PERSONAL_EMAIL)"
        fi

        if [[ "$personal_ssh" == *"$(basename "$PERSONAL_SSH_KEY")"* ]]; then
            print_success "Personal SSH key config correct"
        else
            print_warning "Personal SSH key config: $personal_ssh"
        fi
    fi

    # Summary
    print_header "Setup Complete!"

    if [[ "$INCLUDE_WORK" != true ]]; then
        echo "Configuration files created:"
        echo "  • ~/.gitconfig (personal-only)"
        echo ""
    else
        echo "Configuration files created:"
        echo "  • ~/.gitconfig"
        echo "  • ~/.gitconfig-personal"
        echo ""
    fi

    local missing_keys=false
    if [ "$personal_key_exists" = false ]; then
        missing_keys=true
    fi
    if [[ "$INCLUDE_WORK" == true ]] && [ "$work_key_exists" = false ]; then
        missing_keys=true
    fi

    if [ "$missing_keys" = true ]; then
        print_warning "Missing SSH keys detected. Next steps:"
        echo ""
        if [ "$personal_key_exists" = false ]; then
            echo "  Generate personal key:"
            echo "  ssh-keygen -t ed25519 -C \"$PERSONAL_EMAIL\" -f $PERSONAL_SSH_KEY"
            echo ""
        fi
        if [[ "$INCLUDE_WORK" == true ]] && [ "$work_key_exists" = false ]; then
            echo "  Generate/obtain work key and save to:"
            echo "  $WORK_SSH_KEY"
            echo ""
        fi
        echo "  Then add public keys to GitHub:"
        echo "  https://github.com/settings/keys"
    else
        print_success "All SSH keys found!"
        echo ""
        echo "Test your setup:"
        echo "  ssh -T git@github.com"
    fi
}

# Run the setup
setup_git_configs
