#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Paste Microsoft Online Password
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔑
# @raycast.packageName 1Password

export PATH="/opt/homebrew/bin:$PATH"

password=$(op item get "Microsoftonline" --fields label=password --reveal 2>/dev/null | tr -d '\n')

if [ -n "$password" ]; then
    printf '%s' "$password" | pbcopy
    osascript -e 'tell application "System Events" to keystroke "v" using command down'
else
    osascript -e 'display notification "Failed to fetch password from 1Password" with title "Raycast"'
fi
