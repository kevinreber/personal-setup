---
sidebar_position: 1
slug: /getting-started
---

# Getting Started

This repository contains documentation and automation scripts for setting up a new Mac development environment.

## Fresh Machine Setup

Run this single command to bootstrap everything on a new Mac:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/kevinreber/personal-setup/main/setup.sh)"
```

Or, if you already have the repo cloned:

```bash
./setup.sh
```

This will automatically clone the repo to `~/Projects/personal-setup` and:

1. Install Xcode Command Line Tools
2. Install Homebrew
3. Clone this repo to `~/Projects/personal-setup` (if not already cloned)
4. Install all apps and tools from the Brewfile
5. Install Oh My Zsh + plugins (zsh-syntax-highlighting, zsh-autosuggestions)
6. Restore shell configs (zshrc, tmux, zprofile, etc.)
7. Set up Git config and SSH keys
8. Install the auto-backup launchd service

Each step is **idempotent** — safe to run multiple times. It skips work already done and prompts before overwriting existing files.

## What's Next?

- [GitHub & SSH Setup](/docs/guides/github-ssh-setup) — Configure Git with separate SSH keys for personal and work
- [Shell Config Backup](/docs/guides/shell-config-backup) — Automated backup of your shell configs
- [Project Structure](/docs/reference/project-structure) — Overview of the repository layout
