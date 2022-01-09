#!/usr/bin/env bash

: '
Find and print all github repos under "${GITHUB_PATH}"
'

set -euo pipefail

get_sed_binary(){
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    echo "gsed"
  else
    echo "sed"
  fi
}

get_git_repos(){
  : '
  Return all git repos under GITHUB_PATH
  Remove trailing forward and backslashes
  '
  local github_path="$1"

  find "${github_path}/" \
    -mindepth 3 -maxdepth 3 \
    -type d \
    -name ".git" \
    -printf "%h/\n" | \
  "$(get_sed_binary)" "s%${github_path}%%" | \
  "$(get_sed_binary)" 's%/$%%' | \
  "$(get_sed_binary)" 's%^/%%'
}

# Make sure that "GITHUB_PATH" is defined
if [[ -z "${GITHUB_PATH-}" ]]; then
  exit 1
fi

# Get all git repos
get_git_repos "${GITHUB_PATH}"