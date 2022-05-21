#!/usr/bin/env bash

# Check window size
if [[ "$(basename "${SHELL}")" == "bash" ]]; then
  shopt -s checkwinsize
fi
