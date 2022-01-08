#!/usr/bin/env bash

###########
# FUNCTIONS
###########

## Checkers
check_bin_path(){
  if ! type \
    aws \
    jq >/dev/null 2>&1; then
      return 1
  fi
}

check_aws_version(){
  if [[ "$(aws --version | \
           tr ' ' '\n' | \
           grep '^aws-cli/' | \
           cut -d'/' -f2 | \
           cut -d'.' -f1)" -lt "2" ]]; then
    return 1
  fi
}

#########
# GETTERS
#########
get_instances(){
  : '
  Get the instance
  '
  aws ec2 describe-instances \
          --output json 2>/dev/null | \
        jq --raw-output \
          '.Reservations[] |
           .Instances[] |
           select(.State.Name == "running") |
           .InstanceId'
}

# Check aws and jq are installed
if ! check_bin_path; then
  exit 1
fi

if ! check_aws_version; then
  exit 1
fi

get_instances

