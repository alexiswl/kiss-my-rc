#!/usr/bin/env bash

: '
Simple functions for logging into aws sso

Exported Functions

* aws_<workgroup>
  * Run a command in a specific aws workgroup

* aws_sso_<workgroup>
  * Log into a specific aws workgroup
'

##########
# GLOBALS
##########

# AWS aliases
DEV_PROFILE="843407916570_AdministratorAccess"
PROD_PROFILE="472057503814_AdministratorAccess"
TOTHILL_PROFILE="206808631540_AdministratorAccess"

# Set default profile to DEV_PROFILE
export AWS_PROFILE="${DEV_PROFILE}"

###################
# Primary Functions
###################

_aws() {
  : '
  Run with a specific profile
  '
  eval aws '"${@}"'
}

_aws_sso() {
  : '
  Force aws2 path, otherwise cant be used in aws1 envs such as parallel cluster
  '
	aws2 sso login --profile="$1"
}

###################
# Per-env functions
###################

aws_tothill(){
  AWS_PROFILE="${TOTHILL_PROFILE}" _aws "$@"
}

aws_dev(){
  AWS_PROFILE="${DEV_PROFILE}" _aws "$@"
}

aws_sso_dev() {
	_aws_sso "${DEV_PROFILE}"
}

aws_sso_tothill() {
	_aws_sso "${TOTHILL_PROFILE}"
}

aws_sso_prod() {
  _aws_sso "${PROD_PROFILE}"
}