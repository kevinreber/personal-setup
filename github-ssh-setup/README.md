# GitHub & SSH Setup

This directory contains documentation and automation scripts for setting up Git configuration with separate SSH keys for personal and work projects.

## Files

- **`github-ssh-setup.md`** - Complete documentation and manual setup guide
- **`setup-git-config.sh`** - Automated setup script for Git configuration
- **`README.md`** - This file

## Quick Start

### New Laptop Setup

1. **Copy or generate SSH keys** (see detailed guide in `github-ssh-setup.md`)

2. **Run the automated setup script:**
   ```bash
   ./setup-git-config.sh
   ```

   This script will:
   - Check for existing SSH keys
   - Backup existing Git config files
   - Create `~/.gitconfig` with work defaults
   - Create `~/.gitconfig-personal` for personal projects
   - Set correct SSH key permissions
   - Verify the configuration

3. **Follow any additional instructions** from the script output

### Manual Setup

If you prefer to set up manually or need more details, see the complete guide in `github-ssh-setup.md`.

## Configuration Overview

After setup:
- **Personal projects** (`~/Documents/code/personal/`):
  - Email: `kevinreber1@gmail.com`
  - SSH Key: `~/.ssh/id_ed25519_kevinreber_personal`

- **Work projects** (all other directories):
  - Email: `kreber@linkedin.com`
  - SSH Key: `~/.ssh/kreber_at_linkedin.com_ssh_key`

## Testing Your Setup

```bash
# Test in work directory
cd ~/Documents/code/some-work-repo
git config user.email          # Should show: kreber@linkedin.com

# Test in personal directory
cd ~/Documents/code/personal/some-personal-repo
git config user.email          # Should show: kevinreber1@gmail.com

# Test SSH connection
ssh -T git@github.com
```

## Troubleshooting

See the troubleshooting section in `github-ssh-setup.md` for common issues and solutions.
