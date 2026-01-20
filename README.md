# Personal Setup Documentation

This repository contains documentation and automation scripts for setting up a new laptop or development environment.

## Directory Structure

```
personal-setup/
├── README.md                    # This file
└── github-ssh-setup/           # GitHub & SSH configuration
    ├── README.md               # Quick start guide
    ├── github-ssh-setup.md     # Detailed documentation
    └── setup-git-config.sh     # Automated setup script
```

## Setup Guides

### GitHub & SSH Configuration
Location: `github-ssh-setup/`

Configures Git to automatically use different SSH keys based on directory:
- Personal projects: `kevinreber1@gmail.com` with personal SSH key
- Work projects: `kreber@linkedin.com` with LinkedIn SSH key

**Quick setup:** Run `./github-ssh-setup/setup-git-config.sh`

---

## Future Documentation

This repository will expand to include setup guides for:
- Development tools configuration
- Shell/terminal setup
- Application preferences
- System configuration
- And more...

## Usage

Each directory contains:
- Detailed documentation (`.md` files)
- Automation scripts (`.sh` files where applicable)
- A README explaining the setup

Browse the directories above or check the individual READMEs for specific setup instructions.
