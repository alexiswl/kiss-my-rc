#!/usr/bin/env bash

# Turn off the bell
if [[ "${SHELL}" == "bash" ]]; then
  bind "set bell-style none"
elif [[ "${SHELL}" == "zsh" ]]; then
  unsetopt BEEP
fi
