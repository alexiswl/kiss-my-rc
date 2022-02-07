#!/usr/bin/env bash

: '
Enables us to easily find our repo we"re looking for
go_to_git <tab><tab> then yields all of the git repos we can find in the GITHUB_PATH variable
'

go_to_git() {
  : '
  Prepend the GITHUB_PATH with the auto_completion
  '
  cd "${GITHUB_PATH}/$1" || return
}
