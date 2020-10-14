#!/usr/bin/env bash

: '
Simple functions for logging into aws sso
'

##########
# GLOBALS
##########

# AWS aliases
DEV_PROFILE="843407916570_AdministratorAccess"
TOTHILL_PROFILE="206808631540_AdministratorAccess"

# Set default profile to DEV_PROFILE
export AWS_PROFILE="${DEV_PROFILE}"

###########
# FUNCTIONS
###########

_aws() {
  : '
  Run with a specific profile
  '
  local profile="$1"
  aws "${@}" --profile="${profile}"
}

_aws_sso() {
	aws2 sso login --profile="$1"
}

aws_tothill(){
  _aws "${TOTHILL_PROFILE}"
}

aws_dev(){
  _aws "${DEV_PROFILE}"
}

aws_sso_dev() {
	_aws_sso "${DEV_PROFILE}"
}

aws_sso_tothill() {
	_aws_sso "${TOTHILL_PROFILE}"
}