---
sidebar_position: 1
---

# Project Structure

Overview of the repository layout and what each directory contains.

```
personal-setup/
├── .gitignore                   # Root gitignore (OS artifacts, editor temps, .env)
├── CLAUDE.md                    # AI assistant guidance
├── README.md                    # Primary documentation
├── setup.sh                     # Main bootstrap script (run on fresh Mac)
├── docs/                        # Docusaurus documentation site
├── github-ssh-setup/            # GitHub & SSH configuration
│   ├── README.md
│   ├── github-ssh-setup.md      # Detailed SSH setup documentation
│   └── setup-git-config.sh      # Automated gitconfig + SSH key setup
├── homebrew-install/            # Homebrew package management
│   └── Brewfile                 # Managed apps/tools list (auto-updated by backup)
└── shell-config/                # Shell config backup & sync
    ├── README.md
    ├── backup-configs.sh        # Backup script (copies ~/ configs here)
    ├── install-backup-service.sh # Installs/manages launchd service
    ├── com.personal-setup.config-backup.plist  # launchd template
    ├── zshrc                    # Backed-up ~/.zshrc
    ├── zprofile                 # Backed-up ~/.zprofile
    ├── tmux.conf                # Backed-up ~/.tmux.conf
    ├── gitconfig                # Backed-up ~/.gitconfig
    ├── gitconfig-personal       # Backed-up ~/.gitconfig-personal
    ├── npmrc                    # Backed-up ~/.npmrc
    └── nvim/                    # Backed-up ~/.config/nvim/
        ├── init.lua
        └── lazy-lock.json
```

## Key Directories

### `github-ssh-setup/`

Contains scripts and documentation for configuring Git with separate SSH keys for personal and work use. Uses Git's `includeIf` directive for automatic directory-based switching.

### `homebrew-install/`

Contains the `Brewfile` which lists all Homebrew-managed apps, CLI tools, and cask applications. This file is auto-updated by the backup script whenever it runs.

### `shell-config/`

Backup system for shell configuration files. The backup script copies config files from `~/` into this directory, and the launchd service runs it automatically every 6 hours.

### `docs/`

This Docusaurus documentation site. Built with React and deployed to GitHub Pages.
