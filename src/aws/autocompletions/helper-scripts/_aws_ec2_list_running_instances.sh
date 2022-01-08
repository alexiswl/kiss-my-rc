#!/usr/bin/env bash

###########
# FUNCTIONS
###########

## Checkers
check_bin_path(){
  if ! type \
    shortcuts-aws \
    jq 2>/dev/null; then
      return 1
  fi
}

check_aws_version(){
  if [[ "$(shortcuts-aws --version | \
           tr ' ' '\n' | \
           grep '^shortcuts-aws-cli/' | \
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
  shortcuts-aws ec2 describe-instances \
          --output json 2>/dev/null | \
        jq --raw-output \
          '.Reservations[] |
           .Instances[] |
           select(.State.Name == "running") |
           .InstanceId'
}


# Check shortcuts-aws and jq are installed
if ! check_bin_path; then
  exit 1
fi

if ! check_aws_version; then
  exit 1
fi

get_instances

