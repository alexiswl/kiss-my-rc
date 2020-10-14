#!/usr/bin/env bash

: '
Enables us to easily find our repo we"re looking for
go_to <tab><tab> then yields all of the git repos we can find in the GITHUB_PATH variable
# TODO app-spec find -maxdepth 2 -type f -name '.git' etc.
'

GITHUB_PATH=""

_go_to() {
  # TODO - check if folder exists first
  cd "$1"
}

go_to_infrastructure() {

  cd "${GITHUB_PATH}/UMCCR/infrastructure"
}

go_to_cwl_iap() {
  cd "${GITHUB_PATH}/UMCCR-ILLUMINA/cwl-iap"
}