#!/usr/bin/env bash

# Set the display environment variable
export DISPLAY=$(ip route list default | awk '{print $3}'):0
export LIBGL_ALWAYS_INDIRECT=1
