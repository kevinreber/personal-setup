# Personal Setup Documentation

This repository contains documentation and automation scripts for setting up a new laptop or development environment.

## Fresh Machine Setup

Run this single command to bootstrap everything on a new Mac:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kevinreber/personal-setup/main/setup.sh)"
```

Or, if you already have the repo cloned:

```bash
./setup.sh
```

This will automatically:
1. Install Xcode Command Line Tools
2. Install Homebrew
3. Clone this repo (if not already cloned)
4. Install all apps and tools from the Brewfile
5. Restore shell configs (zshrc, tmux, zprofile, etc.)
6. Set up Git config and SSH keys
7. Install the auto-backup launchd service

## Directory Structure

```
personal-setup/
├── README.md                    # This file
├── setup.sh                     # Bootstrap script for fresh machine setup
├── github-ssh-setup/           # GitHub & SSH configuration
│   ├── README.md               # Quick start guide
│   ├── github-ssh-setup.md     # Detailed documentation
│   └── setup-git-config.sh     # Automated setup script
├── homebrew-install/           # Homebrew package list
│   └── Brewfile                # All installed apps/tools (auto-updated by backup)
└── shell-config/               # Shell config backup & sync
    ├── README.md               # Setup instructions
    ├── backup-configs.sh       # Backup script
    ├── install-backup-service.sh  # Service installer
    └── com.personal-setup.config-backup.plist  # launchd config
```

## Setup Guides

### GitHub & SSH Configuration
Location: `github-ssh-setup/`

Configures Git to automatically use different SSH keys based on directory:
- Personal projects: `kevinreber1@gmail.com` with personal SSH key
- Work projects: `kreber@linkedin.com` with LinkedIn SSH key

**Quick setup:** Run `./github-ssh-setup/setup-git-config.sh`

### Shell Config Backup
Location: `shell-config/`

Automatically backs up your zsh, tmux, and other shell configs:
- Syncs config files from your home directory to this repo
- Commits and pushes changes automatically
- Runs via launchd (every 6 hours) or manually

**Quick setup:** Run `./shell-config/install-backup-service.sh install`

---

## Future Documentation

This repository will expand to include setup guides for:
- Development tools configuration
- Application preferences
- System configuration
- And more...

## Usage

Each directory contains:
- Detailed documentation (`.md` files)
- Automation scripts (`.sh` files where applicable)
- A README explaining the setup

Browse the directories above or check the individual READMEs for specific setup instructions.
