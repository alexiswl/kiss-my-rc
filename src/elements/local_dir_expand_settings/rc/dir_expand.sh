#!/usr/bin/env bash

# Expand directories
if [[ "$(basename "${SHELL}")" == "bash" ]]; then
  shopt -s direxpand
fi
