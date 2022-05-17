#!/usr/bin/env bash

# Append history rather than overwrite
if [[ "${SHELL}" == "bash" ]]; then
  shopt -s histappend
elif [[ "${SHELL}" == "zsh" ]]; then
  setopt APPEND_HISTORY
fi
