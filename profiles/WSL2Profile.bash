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
BASHRC_REPO_PATH="${GITHUB_PATH}/ALEXISWL/bashrc"
MODULEPATH="${MODULEPATH-}:$BASHRC_REPO_PATH/modules"

export DISPLAY
export BROWSER
export WINDOWS_USER_HOME
export GITHUB_PATH
export BASHRC_REPO_PATH
export MODULEPATH

# Load modules
module load my-aws-shortcuts/1.0.0
module load my-local-path-shortcuts/1.0.0
