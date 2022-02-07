#!/usr/bin/env bash

# Set the display environment variable
DISPLAY="$(route.exe print | grep 0.0.0.0 | head -1 | awk '{print $4}'):0.0"

export DISPLAY