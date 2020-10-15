#!/usr/bin/env bash

: '
Enables us to easily find our repo we"re looking for
go_to <tab><tab> then yields all of the git repos we can find in the GITHUB_PATH variable
# TODO app-spec find -maxdepth 2 -type f -name '.git' etc.
'

go_to_git() {
  : '
  Prepend the GITHUB_PATH with the auto_completion
  '
  cd "${GITHUB_PATH}/$1" || return
}