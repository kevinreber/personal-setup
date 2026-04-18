---
sidebar_position: 2
---

# Setup Script Reference

Detailed reference for `setup.sh`, the main bootstrap script.

## Usage

```bash
# On a fresh machine (no git/homebrew yet)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kevinreber/personal-setup/main/setup.sh)"

# Or if already cloned
./setup.sh
```

## What It Does

The script runs 8 steps in order:

| Step | Action | Details |
|------|--------|---------|
| 1 | Install Xcode CLT | Installs Command Line Tools if not present |
| 2 | Install Homebrew | Installs Homebrew package manager |
| 3 | Clone/update repo | Clones to `~/Projects/personal-setup` |
| 4 | Install Brewfile | Installs all apps/tools from `homebrew-install/Brewfile` |
| 5 | Install Oh My Zsh | Installs OMZ + zsh-syntax-highlighting, zsh-autosuggestions |
| 6 | Restore configs | Copies shell configs (zshrc, zprofile, tmux, gitconfig, nvim, etc.) |
| 7 | Git & SSH setup | Runs `setup-git-config.sh` for SSH key configuration |
| 8 | Install backup service | Sets up the launchd auto-backup service |

## Idempotency

Every step is idempotent — safe to run multiple times:

- Checks for existing tools before installing
- Prompts before overwriting existing files
- Skips steps that are already complete

## Environment Variables

The Git/SSH setup step (step 7) supports these environment variables:

| Variable | Default |
|----------|---------|
| `PERSONAL_EMAIL` | `kevinreber1@gmail.com` |
| `WORK_EMAIL` | `kreber@linkedin.com` |
| `USER_NAME` | `Kevin Reber` |
| `PERSONAL_SSH_KEY` | `$HOME/.ssh/id_ed25519_kevinreber_personal` |
| `WORK_SSH_KEY` | `$HOME/.ssh/kreber_at_linkedin.com_ssh_key` |
| `PERSONAL_DIR` | `$HOME/Projects/` |

## Script Modes

The Git setup script (`setup-git-config.sh`) has two modes:

```bash
./setup-git-config.sh          # Personal SSH only (default — e.g. personal laptop)
./setup-git-config.sh --work   # Personal + work SSH keys with directory-based switching
```
