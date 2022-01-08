#!/usr/bin/env bash

: '
My shared .bash aliases
This file should be sourced by .bashrc
'


#export DISPLAY
#export BROWSER

# Get this current file's directory so we can source files from each of the folders
_THIS_DIR="$(dirname "${0:a}")"

# Source ica functions
# shellcheck source=ica/*.sh
for s_file in "${_THIS_DIR}"/ica/*.sh; do
  source "${s_file}"
done

# Source shortcuts-aws functions
# shellcheck source=shortcuts-aws/*.sh
for s_file in "${_THIS_DIR}"/aws/*.sh; do
  source "${s_file}"
done

# Source path bin
# shellcheck source=local_path_shortcuts/*.sh
for s_file in "${_THIS_DIR}"/local_path_shortcuts/*.sh; do
  source "${s_file}"
done

# Set file paths
# Set here as this is very much wsl2 specific
export GITHUB_PATH="/Users/alexislucattini/OneDrive/OneDrive/GitHub/"

# Source path autocompletions
# Use fpath
# Shortcut below needs gnufind
export PATH=/usr/local/opt/findutils/libexec/gnubin:$PATH
export fpath=("${GITHUB_PATH}/ALEXISWL/bashrc/path_shortcuts/auto_completions/zsh/" $fpath)

compinit

unset _THIS_DIR
