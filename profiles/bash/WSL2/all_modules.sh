#!/usr/bin/env bash

: '
My shared .bash aliases
This file should be sourced by .bashrc
'

# Get DISPLAY for WSL2 through resolv.conf
DISPLAY="$(grep "nameserver" "/etc/resolv.conf" | awk '{print $2}'):0"
BROWSER="wslview"

# Set file paths
# Set here as this is very much wsl2 specific
WINDOWS_USER_HOME="$(wslpath "$(powershell.exe 'echo $HOME' 2>/dev/null)" | sed 's/\r//')"
GITHUB_PATH="${WINDOWS_USER_HOME}/OneDrive/GitHub"

KISS_MY_RC_INSTALL_PATH="${HOME}/.kiss_my_rc"
MODULEPATH="${MODULEPATH-}:${KISS_MY_RC_INSTALL_PATH}/modules"

export DISPLAY
export BROWSER
export WINDOWS_USER_HOME
export GITHUB_PATH
export KISS_MY_RC_INSTALL_PATH
export MODULEPATH

# Load local modules
module load my-local-path-shortcuts/1.0.0
module load my-local-display-settings/1.0.0
module load my-local-history-settings/1.0.0
module load my-local-serenity/1.0.0
module load my-local-aliases/1.0.0
module load my-local-extraction-shortcuts/1.0.0

# Load app modules
module load my-aws-shortcuts/1.0.0
