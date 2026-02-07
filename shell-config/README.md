# Shell Config Backup

Automated backup system for zsh, tmux, and other shell configuration files.

## Quick Start

```bash
# Install the automated backup service (runs every 6 hours)
./install-backup-service.sh install

# Or run a backup manually
./install-backup-service.sh run
```

## What Gets Backed Up

By default, the following files from your home directory are synced:

| Source File | Backed Up As |
|-------------|--------------|
| `~/.zshrc` | `zshrc` |
| `~/.tmux.conf` | `tmux.conf` |
| `~/.zprofile` | `zprofile` |
| `~/.zshenv` | `zshenv` |
| `~/.aliases` | `aliases` |
| `~/.functions` | `functions` |

Files that don't exist are skipped automatically.

## Adding More Files

Edit `backup-configs.sh` and add entries to the `CONFIG_FILES` array:

```bash
declare -A CONFIG_FILES=(
    ["$HOME/.zshrc"]="zshrc"
    ["$HOME/.tmux.conf"]="tmux.conf"
    # Add your custom files here:
    ["$HOME/.vimrc"]="vimrc"
    ["$HOME/.config/starship.toml"]="starship.toml"
)
```

For entire directories, add them to the `CONFIG_DIRS` array:

```bash
declare -a CONFIG_DIRS=(
    "$HOME/.config/nvim"
    "$HOME/.config/alacritty"
)
```

## How It Works

1. **Backup Script** (`backup-configs.sh`)
   - Copies config files from your home directory to this repo
   - Compares files to detect changes
   - Commits and pushes only when there are actual changes

2. **Launchd Service** (macOS)
   - Runs the backup script every 6 hours
   - Also runs immediately when your Mac boots/wakes
   - Logs output to `/tmp/config-backup.*.log`

## Service Management

```bash
# Install the service
./install-backup-service.sh install

# Check status
./install-backup-service.sh status

# Remove the service
./install-backup-service.sh uninstall

# Run backup manually (without service)
./install-backup-service.sh run
```

## Customizing the Schedule

Edit the plist file before installing, or edit directly in `~/Library/LaunchAgents/`:

**Run every N seconds:**
```xml
<key>StartInterval</key>
<integer>21600</integer>  <!-- 21600 = 6 hours -->
```

**Run at specific times:**
```xml
<key>StartCalendarInterval</key>
<array>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</array>
```

After editing, reload the service:
```bash
launchctl unload ~/Library/LaunchAgents/com.personal-setup.config-backup.plist
launchctl load ~/Library/LaunchAgents/com.personal-setup.config-backup.plist
```

## Restoring Configs on a New Machine

1. Clone this repository
2. Copy the backed-up configs to your home directory:

```bash
# Example: restore zshrc
cp shell-config/zshrc ~/.zshrc

# Or restore all at once
cp shell-config/zshrc ~/.zshrc
cp shell-config/tmux.conf ~/.tmux.conf
cp shell-config/zprofile ~/.zprofile
# etc.
```

3. Optionally, install the backup service on the new machine

## Logs

- **Backup log**: `shell-config/.backup.log` (committed to repo)
- **Service stdout**: `/tmp/config-backup.stdout.log`
- **Service stderr**: `/tmp/config-backup.stderr.log`

## Using Cron Instead (Alternative)

If you prefer cron over launchd:

```bash
# Edit crontab
crontab -e

# Add this line (runs every 6 hours)
0 */6 * * * /path/to/personal-setup/shell-config/backup-configs.sh >> /tmp/config-backup.log 2>&1
```

## Troubleshooting

**Service not running?**
```bash
# Check if loaded
launchctl list | grep config-backup

# Check logs
cat /tmp/config-backup.stderr.log
```

**Push failing?**
- Ensure SSH keys are configured for this repo
- Check that you have push access to the remote

**Files not being backed up?**
- Verify the source file exists in your home directory
- Check the backup log: `cat shell-config/.backup.log`
