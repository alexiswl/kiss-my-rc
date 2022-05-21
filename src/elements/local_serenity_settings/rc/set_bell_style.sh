#!/usr/bin/env bash

# Turn off the bell
if [[ "$(basename "${SHELL}")" == "bash" ]]; then
  bind "set bell-style none"
elif [[ "$(basename "${SHELL}")" == "zsh" ]]; then
  unsetopt BEEP
fi
