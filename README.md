# Personal Setup Documentation

This repository contains documentation and automation scripts for setting up a new laptop or development environment.

## Directory Structure

```
personal-setup/
├── README.md                    # This file
├── github-ssh-setup/           # GitHub & SSH configuration
│   ├── README.md               # Quick start guide
│   ├── github-ssh-setup.md     # Detailed documentation
│   └── setup-git-config.sh     # Automated setup script
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
