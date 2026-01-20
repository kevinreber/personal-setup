# GitHub & SSH Configuration Setup Guide

This guide explains how to set up Git to automatically use different SSH keys based on the directory you're working in.

## Overview

- **Personal projects** (under `~/Documents/code/personal/`):
  - Email: `kevinreber1@gmail.com`
  - SSH Key: `~/.ssh/id_ed25519_kevinreber_personal`

- **LinkedIn/Work projects** (all other directories):
  - Email: `kreber@linkedin.com`
  - SSH Key: `~/.ssh/kreber_at_linkedin.com_ssh_key`

---

## Setup Steps for a New Laptop

### 1. SSH Keys Setup

#### Option A: Copy Existing Keys (Recommended)

On your old laptop, copy these files:
```bash
~/.ssh/id_ed25519_kevinreber_personal
~/.ssh/id_ed25519_kevinreber_personal.pub
~/.ssh/kreber_at_linkedin.com_ssh_key
~/.ssh/kreber_at_linkedin.com_ssh_key.pub
```

On your new laptop:
```bash
# Copy the files to ~/.ssh/
# Then set correct permissions (CRITICAL!)
chmod 600 ~/.ssh/id_ed25519_kevinreber_personal
chmod 600 ~/.ssh/kreber_at_linkedin.com_ssh_key
chmod 644 ~/.ssh/*.pub
```

#### Option B: Generate New Keys

```bash
# Generate new personal key
ssh-keygen -t ed25519 -C "kevinreber1@gmail.com" -f ~/.ssh/id_ed25519_kevinreber_personal

# LinkedIn key - regenerate through LinkedIn's onboarding process
```

If you generate new keys, you'll need to add the public keys to GitHub:
```bash
# Copy personal key to clipboard
cat ~/.ssh/id_ed25519_kevinreber_personal.pub | pbcopy
# Then add to: https://github.com/settings/keys
```

---

### 2. Git Configuration Files

Create two Git config files:

#### `~/.gitconfig` (Main Configuration)

```ini
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
```

#### `~/.gitconfig-personal` (Personal Projects Configuration)

```ini
# Personal Git configuration
# This config is automatically loaded for repositories under ~/Documents/code/personal/

[user]
	name = Kevin Reber
	email = kevinreber1@gmail.com

[core]
	sshCommand = "ssh -i ~/.ssh/id_ed25519_kevinreber_personal -o IdentitiesOnly=yes"
```

---

### 3. SSH Config (Optional - Already Managed by LinkedIn)

Your `~/.ssh/config` is managed by LinkedIn automation, but you can add custom settings to `~/.ssh/config.custom` if needed.

Current custom config handles GitHub aliases:
```ssh
# Default GitHub to personal account
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_kevinreber_personal
    IdentitiesOnly yes
    IdentityAgent none
    PreferredAuthentications publickey

# LinkedIn GitHub account alias
Host github.com-linkedin
    HostName github.com
    User git
    IdentityFile ~/.ssh/kreber_at_linkedin.com_ssh_key
    IdentitiesOnly yes
```

---

### 4. Verify the Setup

Test that Git is using the correct configuration:

```bash
# Test personal directory
cd ~/Documents/code/personal/some-repo
git config user.email          # Should show: kevinreber1@gmail.com
git config core.sshCommand     # Should show: ssh -i ~/.ssh/id_ed25519_kevinreber_personal -o IdentitiesOnly=yes

# Test work directory
cd ~/Documents/code/some-work-repo
git config user.email          # Should show: kreber@linkedin.com
git config core.sshCommand     # Should show: ssh -i ~/.ssh/kreber_at_linkedin.com_ssh_key -o IdentitiesOnly=yes
```

Test SSH connections:
```bash
# Test personal GitHub
ssh -T git@github.com

# Test LinkedIn GitHub (if applicable)
ssh -T git@github.com-linkedin
```

---

## How It Works

### Conditional Includes

The key to this setup is Git's `includeIf` directive in `~/.gitconfig`:

```ini
[includeIf "gitdir:~/Documents/code/personal/"]
	path = ~/.gitconfig-personal
```

When you're in any Git repository under `~/Documents/code/personal/`:
1. Git loads the main `~/.gitconfig` first (with LinkedIn defaults)
2. Then Git checks the `includeIf` conditions
3. If the condition matches, it loads `~/.gitconfig-personal`
4. Settings in the included file override the defaults

This means:
- No manual switching required
- Automatic based on directory location
- Clean separation between work and personal projects

---

## Troubleshooting

### Wrong email/key being used

Check which config is being loaded:
```bash
git config --show-origin user.email
git config --show-origin core.sshCommand
```

### Permission denied (publickey)

Check SSH key permissions:
```bash
ls -la ~/.ssh/
# Private keys should be 600 (rw-------)
# Public keys should be 644 (rw-r--r--)
```

Fix permissions:
```bash
chmod 600 ~/.ssh/id_ed25519_kevinreber_personal
chmod 644 ~/.ssh/id_ed25519_kevinreber_personal.pub
```

### Test SSH connection

```bash
# Add -v for verbose output to debug
ssh -vT git@github.com
```

---

## Quick Setup Checklist

- [ ] Copy or generate SSH keys
- [ ] Set correct permissions on SSH keys (600 for private, 644 for public)
- [ ] Add public keys to GitHub accounts
- [ ] Create `~/.gitconfig` with LinkedIn defaults and conditional include
- [ ] Create `~/.gitconfig-personal` with personal settings
- [ ] Test configuration in both personal and work directories
- [ ] Test SSH connections to GitHub

---

## Additional Resources

- [GitHub SSH Key Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Git Conditional Includes](https://git-scm.com/docs/git-config#_conditional_includes)
- LinkedIn SSH Setup: Contact IT or check internal documentation
