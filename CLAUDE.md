# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**personal-setup** is a collection of bash scripts, shell configs, and documentation for bootstrapping and maintaining Kevin's Mac development environment. It serves as both documentation and automation for setting up a new machine.

**Important**: This repo contains shell configuration files and scripts that affect the host system. Be careful with destructive operations and always verify changes before applying them.

## Repository Purpose

This is primarily a **documentation and scripting** repo — not a software project to build. There is no build step, no test suite, and no deployment pipeline. The "output" is a properly configured Mac.

## Project Structure

```
personal-setup/
├── CLAUDE.md                    # This file — AI assistant guidance
├── README.md                    # Primary documentation
├── setup.sh                     # Main bootstrap script (run on fresh Mac)
├── .claude/
│   ├── settings.json            # Claude Code hooks config
│   └── agents/
│       └── script-reviewer.md   # Custom agent for shell script review
├── github-ssh-setup/            # GitHub & SSH configuration
│   ├── README.md
│   ├── github-ssh-setup.md      # Detailed SSH setup documentation
│   └── setup-git-config.sh      # Automated gitconfig + SSH key setup
├── homebrew-install/            # Homebrew package management
│   └── Brewfile                 # Managed apps/tools list (auto-updated by backup)
└── shell-config/                # Shell config backup & sync
    ├── README.md
    ├── .gitignore               # Ignores .backup.log
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

## What the Scripts Do

### setup.sh (main bootstrap)

Run on a fresh Mac. Executes 7 steps:
1. Install Xcode Command Line Tools
2. Install Homebrew
3. Clone or update this repo (to `~/Documents/code/personal/personal-setup`)
4. Install all apps/tools from `homebrew-install/Brewfile`
5. Restore shell configs (zshrc, zprofile, tmux, gitconfig, npmrc, nvim, etc.)
6. Set up Git config and SSH keys (via `setup-git-config.sh`)
7. Install the auto-backup launchd service

Each step is idempotent — skips work already done and prompts before overwriting existing files.

**Usage**:
```bash
# On a fresh machine (no git/homebrew yet)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kevinreber/personal-setup/main/setup.sh)"

# Or if already cloned
./setup.sh
```

### shell-config/backup-configs.sh

Copies shell config files from `~/` to this repo, regenerates the Brewfile from installed Homebrew packages, syncs the nvim config directory, then commits and pushes if changes are detected. Run automatically via launchd every 6 hours.

**Backed-up files**: `.zshrc`, `.tmux.conf`, `.zprofile`, `.zshenv`, `.aliases`, `.functions`, `.gitconfig`, `.gitconfig-personal`, `.npmrc`, and `~/.config/nvim/` directory.

**Usage**:
```bash
./shell-config/backup-configs.sh
```

### shell-config/install-backup-service.sh

Installs/manages the launchd service that auto-runs the backup script.

```bash
./shell-config/install-backup-service.sh install    # Install and start
./shell-config/install-backup-service.sh uninstall  # Remove service
./shell-config/install-backup-service.sh status     # Show status + recent logs
./shell-config/install-backup-service.sh run        # Run backup immediately (no install)
```

### github-ssh-setup/setup-git-config.sh

Configures Git to use different SSH keys based on directory via `includeIf`:
- Personal projects (`~/Documents/code/personal/`): `kevinreber1@gmail.com` with `~/.ssh/id_ed25519_kevinreber_personal`
- Work projects (default): `kreber@linkedin.com` with `~/.ssh/kreber_at_linkedin.com_ssh_key`

Creates `~/.gitconfig` and `~/.gitconfig-personal`, backs up existing files before overwriting, and verifies the configuration.

## Working with this Repo

### Updating Shell Configs

The `.zshrc`, `.gitconfig`, etc. in `shell-config/` are **backups from the host machine**. They are NOT templates to edit directly. To update:

1. Edit the file on the host machine (`~/.zshrc`)
2. Run `./shell-config/backup-configs.sh` to sync to this repo
3. Commit and push

### Updating the Brewfile

The `homebrew-install/Brewfile` is auto-updated by the backup script. To manually update:

```bash
brew bundle dump --file=homebrew-install/Brewfile --force
```

### Adding New Setup Steps

Add new steps to `setup.sh`. Keep each step idempotent (safe to run multiple times).

## Code Conventions

### Shell Scripts

- Use `#!/bin/bash` shebang (not `#!/bin/zsh`)
- `set -e` for error-on-failure (where appropriate)
- Check for existing tools before installing
- Print clear status messages with colored output helpers (`log`, `log_success`, `log_warning`, `log_error`)
- Use functions for logical groupings of steps
- Use `$HOME` instead of `~` in scripts (safer expansion)
- Quote all variable expansions (e.g., `"$HOME/.zshrc"` not `$HOME/.zshrc`)

### Safety

- Never hardcode passwords or API keys
- Destructive operations (rm, overwrite) should prompt for confirmation or check first
- Back up existing files before overwriting (timestamped `.backup.*` files)
- SSH key operations should check for existing keys before generating

## Automated Hooks and Agents

### Claude Code Hooks

Configured in `.claude/settings.json`. Automatically run after editing or writing `.sh` files:
- `bash -n` syntax check on any shell script modified via the Edit or Write tools

### Custom Agents

- **script-reviewer** (`.claude/agents/script-reviewer.md`): Reviews shell scripts for safety, idempotency, correctness, and common issues. Use when reviewing changes to any `.sh` files in this repo.
