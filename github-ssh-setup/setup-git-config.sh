#!/bin/bash

################################################################################
# Git Configuration Setup Script
#
# This script automates the setup of Git configuration files to use different
# SSH keys based on directory location:
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

# Configuration
PERSONAL_EMAIL="kevinreber1@gmail.com"
WORK_EMAIL="kreber@linkedin.com"
USER_NAME="Kevin Reber"
PERSONAL_SSH_KEY="~/.ssh/id_ed25519_kevinreber_personal"
WORK_SSH_KEY="~/.ssh/kreber_at_linkedin.com_ssh_key"
PERSONAL_DIR="~/Documents/code/personal/"

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
    local key_path=$(eval echo $1)
    if [ ! -f "$key_path" ]; then
        print_error "SSH key not found: $key_path"
        return 1
    fi
    print_success "SSH key found: $key_path"
    return 0
}

# Check SSH key permissions
check_ssh_permissions() {
    local key_path=$(eval echo $1)
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

    if ! check_ssh_key "$WORK_SSH_KEY"; then
        work_key_exists=false
        print_warning "Work SSH key not found. You'll need to generate or copy it."
    else
        check_ssh_permissions "$WORK_SSH_KEY"
    fi

    # Step 2: Create ~/.gitconfig-personal
    print_info "\nCreating ~/.gitconfig-personal..."
    backup_file "$HOME/.gitconfig-personal"

    cat > "$HOME/.gitconfig-personal" << 'EOF'
# Personal Git configuration
# This config is automatically loaded for repositories under ~/Documents/code/personal/

[user]
	name = Kevin Reber
	email = kevinreber1@gmail.com

[core]
	sshCommand = "ssh -i ~/.ssh/id_ed25519_kevinreber_personal -o IdentitiesOnly=yes"
EOF

    print_success "Created ~/.gitconfig-personal"

    # Step 3: Update or create ~/.gitconfig
    print_info "\nUpdating ~/.gitconfig..."

    if [ -f "$HOME/.gitconfig" ]; then
        # Check if conditional include already exists
        if grep -q "includeIf.*gitdir:~/Documents/code/personal/" "$HOME/.gitconfig"; then
            print_info "Conditional include already exists in ~/.gitconfig"
        else
            print_info "Adding conditional include to existing ~/.gitconfig"
            backup_file "$HOME/.gitconfig"

            # Add conditional include if not present
            if ! grep -q "^\[core\]" "$HOME/.gitconfig"; then
                # Add core section with sshCommand
                sed -i '' '/^\[user\]/a\
[core]\
	sshCommand = "ssh -i ~/.ssh/kreber_at_linkedin.com_ssh_key -o IdentitiesOnly=yes"
' "$HOME/.gitconfig"
            elif ! grep -q "sshCommand" "$HOME/.gitconfig"; then
                # Add sshCommand to existing core section
                sed -i '' '/^\[core\]/a\
	sshCommand = "ssh -i ~/.ssh/kreber_at_linkedin.com_ssh_key -o IdentitiesOnly=yes"
' "$HOME/.gitconfig"
            fi

            # Add conditional include at the end
            echo "" >> "$HOME/.gitconfig"
            echo "# Conditional includes - use personal config for personal projects" >> "$HOME/.gitconfig"
            echo "[includeIf \"gitdir:~/Documents/code/personal/\"]" >> "$HOME/.gitconfig"
            echo "	path = ~/.gitconfig-personal" >> "$HOME/.gitconfig"

            print_success "Updated ~/.gitconfig with conditional include"
        fi
    else
        # Create new .gitconfig
        cat > "$HOME/.gitconfig" << 'EOF'
[user]
	name = Kevin Reber
	email = kreber@linkedin.com

[core]
	sshCommand = "ssh -i ~/.ssh/kreber_at_linkedin.com_ssh_key -o IdentitiesOnly=yes"

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
[includeIf "gitdir:~/Documents/code/personal/"]
	path = ~/.gitconfig-personal
EOF

        print_success "Created ~/.gitconfig"
    fi

    # Step 4: Verify setup
    print_header "Verification"

    print_info "Testing configuration..."

    # Test in a work directory
    if [ -d "$HOME/Documents/code" ]; then
        cd "$HOME/Documents/code"
        local work_email=$(git config user.email)
        local work_ssh=$(git config core.sshCommand)

        if [ "$work_email" = "$WORK_EMAIL" ]; then
            print_success "Work directory config correct: $work_email"
        else
            print_error "Work directory config incorrect: $work_email (expected: $WORK_EMAIL)"
        fi

        if [[ "$work_ssh" == *"kreber_at_linkedin.com_ssh_key"* ]]; then
            print_success "Work SSH key config correct"
        else
            print_warning "Work SSH key config: $work_ssh"
        fi
    fi

    # Test in a personal directory (if exists)
    if [ -d "$HOME/Documents/code/personal" ]; then
        cd "$HOME/Documents/code/personal"
        local personal_email=$(git config user.email)
        local personal_ssh=$(git config core.sshCommand)

        if [ "$personal_email" = "$PERSONAL_EMAIL" ]; then
            print_success "Personal directory config correct: $personal_email"
        else
            print_error "Personal directory config incorrect: $personal_email (expected: $PERSONAL_EMAIL)"
        fi

        if [[ "$personal_ssh" == *"id_ed25519_kevinreber_personal"* ]]; then
            print_success "Personal SSH key config correct"
        else
            print_warning "Personal SSH key config: $personal_ssh"
        fi
    fi

    # Summary
    print_header "Setup Complete!"

    echo "Configuration files created:"
    echo "  • ~/.gitconfig"
    echo "  • ~/.gitconfig-personal"
    echo ""

    if [ "$personal_key_exists" = false ] || [ "$work_key_exists" = false ]; then
        print_warning "Missing SSH keys detected. Next steps:"
        echo ""
        if [ "$personal_key_exists" = false ]; then
            echo "  Generate personal key:"
            echo "  ssh-keygen -t ed25519 -C \"$PERSONAL_EMAIL\" -f ~/.ssh/id_ed25519_kevinreber_personal"
            echo ""
        fi
        if [ "$work_key_exists" = false ]; then
            echo "  Generate/obtain work key and save to:"
            echo "  ~/.ssh/kreber_at_linkedin.com_ssh_key"
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
