#!/usr/bin/env bash

# Set primary functions
_get_find_binary(){
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    echo "gfind"
  else
    echo "find"
  fi
}

_directory_not_empty(){
  : '
  Ensure a directory is not empty
  '
  local directory_name="$1"

  if [[ ! -d "${directory_name}" ]]; then
    return 1
  fi

  if [[ "$("$(_get_find_binary)" "${directory_name}" -maxdepth 0 -mindepth 0 -empty | wc -l)" == "1" ]]; then
    return 1
  else
    return 0
  fi
}

_add_bin_to_path(){
  # Add bin to path
  if [[ -d "${_THIS_DIR}/bin/" ]]; then
    export PATH="${_THIS_DIR}/bin/:${PATH-}"
  fi
}

# Set env vars
_THIS_DIR="$(dirname "${BASH_SOURCE[0]}")"  # Should resolve to the directory this file is linked to
_THIS_SHELL="$(basename "${SHELL}")"

# source functions
if _directory_not_empty "${_THIS_DIR}/fbin/"; then
  if [[ "${_THIS_SHELL}" == "bash" ]]; then
    # Source files in fbin/ given fbin exists and is not empty
    # shellcheck source=directory/fbin/*.sh
    for s_file in "${_THIS_DIR}/fbin/"*.sh; do
      source "${s_file}"
    done
  elif [[ "${_THIS_SHELL}" == "zsh" ]]; then
    export fpath=( "${_THIS_DIR}/fbin/" ${fpath-} )
  fi
fi

# Source binaries
_add_bin_to_path

# Source auto-completion functions
# Add bash / zsh
if [[ "${_THIS_SHELL}" == "bash" ]]; then
  if _directory_not_empty "${_THIS_DIR}/autocompletions/bash/"; then
    # Source files in autocompletion given autocompletion directory exists
    # shellcheck source=shortcuts-aws/autocompletions/bash/*bash
    for s_file in "${_THIS_DIR}/autocompletions/bash/"*.bash; do
      source "${s_file}"
    done
  fi
elif [[ "${_THIS_SHELL}" == "zsh" ]]; then
  if _directory_not_empty "${_THIS_DIR}/autocompletions/bash/"; then
    # Source files in fbin/ given fbin exists and is not empty
    # shellcheck source=shortcuts-aws/fbin/*.sh
    export fpath=( "${_THIS_DIR}/autocompletions/zsh/" ${fpath-} )
  fi
fi