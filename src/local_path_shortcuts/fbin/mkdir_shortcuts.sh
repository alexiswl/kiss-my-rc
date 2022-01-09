#!/usr/bin/env bash

# Make directory and then go there

mkdirg(){
  : '
  # From https://gist.github.com/zachbrowne/8bc414c9f30192067831fafebd14255c
  '
	mkdir -p "${1}"
	cd "${1}"
}

mkscratchg(){
  cd "$(mktemp -d)" || return
}