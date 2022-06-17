#!/usr/bin/env bash

# Append history rather than overwrite
if [[ "$(basename "${SHELL}")" == "bash" ]]; then
  shopt -s histappend
elif [[ "$(basename "${SHELL}")" == "zsh" ]]; then
  setopt APPEND_HISTORY
fi
