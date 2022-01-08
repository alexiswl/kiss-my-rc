#!/usr/bin/env bash

: '
List s3 files and folders as one would with ls

This script does the following
1. Prints the list of files and folders given the variable $CURRENT_WORD
'

set -euo pipefail

###########
# FUNCTIONS
###########

## Checkers
check_bin_path(){
  if ! type \
    shortcuts-aws \
    python3 \
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

check_s3_prefix(){
  : '
  Sub function, before we continue, make sure that the argument starts with s3://
  '
  # Input vars
  local s3_path="$1"

  # Local vars
  local scheme

  scheme="$(python3 -c "from urllib.parse import urlparse; print(urlparse(\"${s3_path}\").scheme)")"

  # Function doesn't output anything, just a non-zero return value if the scheme variable is not s3
  if [[ ! "${scheme}" == "s3" ]]; then
    return 1
  fi
}

check_bucket(){
  : '
  Check that the bucket is a bucket
  '
  # Input vars
  local bucket_name="$1"

  # Print bucket
  if [[ "$(shortcuts-aws s3api list-buckets --output json | \
           jq '.Buckets[].Name' | \
           grep -c "^${bucket_name}$")" == "0" ]] ; then
    return 1
  else
    return 0
  fi
}

#########
# GETTERS
#########
get_bucket_name(){
  : '
  Get the bucket name from the s3 path
  '
  # Get inputs
  local s3_path="$1"

  # Function outputs
  python3 -c "from urllib.parse import urlparse; print(urlparse(\"${s3_path}\").netloc)"
}

get_key_prefix(){
  # Get inputs
  local s3_path="$1"

  # Function outputs
  python3 -c "from urllib.parse import urlparse; print(urlparse(\"${s3_path}\").path)"
}

##########
# PRINTERS
##########
print_buckets(){
  : '
  Print s3 buckets
  '
  shortcuts-aws s3api list-buckets \
    --output json | \
  jq --raw-output \
    '"s3://" + .Buckets[].Name'
}

print_prefixes_and_files(){
  : '
  List all folders

  '
  # Inputs
  local bucket="$1"  # Buckets
  local prefix="${2-}"  # Prefix

  # Locals
  local delimiter="/"

  # Print outputs
  shortcuts-aws s3api list-objects-v2 \
    --bucket "${bucket}" \
    --prefix "${prefix}" \
    --delimiter "${delimiter}" \
    --output json | \
  jq --raw-output \
    --arg bucket "${bucket}" \
    '"s3://" + $bucket + "/" + ((.Contents[]? | .Key), (.CommonPrefixes[]? | .Prefix))' | \
  sort
}

########
# INPUTS
########
s3_path="${1:-s3://}"
# Strip quotes from name
s3_path="${s3_path%\"}"
s3_path="${s3_path#\"}"


# Check prompt starts with s3
if ! check_s3_prefix "${s3_path}"; then
  : '
  Nothing to return - we just echo "s3://"
  '
  echo "s3://"
fi

# Get the bucket name
bucket_name="$(get_bucket_name "${s3_path}")"
key_prefix="$(get_key_prefix "${s3_path}")"

if [[ -z "${bucket_name}" ]]; then
  print_buckets
  exit
fi

# Check volume exists - if not print all volumes
if ! check_bucket "${bucket_name}"; then
  print_buckets
  exit
fi

# Print both files and subfolders simultaneously
print_files_and_subfolders "${bucket_name}" "${key_prefix}"