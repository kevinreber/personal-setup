---
sidebar_position: 2
---

# GitHub & SSH Quick Start

Quick setup guide for Git configuration with separate SSH keys.

## Steps

1. **Copy or generate SSH keys** (see [detailed guide](./github-ssh-setup))

2. **Run the automated setup script:**
   ```bash
   ./github-ssh-setup/setup-git-config.sh
   ```

   This script will:
   - Check for existing SSH keys
   - Backup existing Git config files
   - Create `~/.gitconfig` with work defaults
   - Create `~/.gitconfig-personal` for personal projects
   - Set correct SSH key permissions
   - Verify the configuration

3. **Follow any additional instructions** from the script output

## Configuration After Setup

| Context | Email | SSH Key |
|---------|-------|---------|
| Personal projects (`~/Projects/`) | `kevinreber1@gmail.com` | `~/.ssh/id_ed25519_kevinreber_personal` |
| Work projects (all other dirs) | `kreber@linkedin.com` | `~/.ssh/kreber_at_linkedin.com_ssh_key` |

## Testing Your Setup

```bash
# Test in work directory
cd ~/Documents/code/some-work-repo
git config user.email          # Should show: kreber@linkedin.com

# Test in personal directory
cd ~/Projects/some-personal-repo
git config user.email          # Should show: kevinreber1@gmail.com

# Test SSH connection
ssh -T git@github.com
```

## Need More Details?

See the [full GitHub & SSH Configuration guide](./github-ssh-setup) for manual setup, how conditional includes work, and troubleshooting.
