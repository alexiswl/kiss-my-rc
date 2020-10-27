#!/usr/bin/env bash

: '
Set of functions designed to quickly collect iap session tokens
You are expected to have installed https://github.com/mikefarah/yq globally,
on at least version 3.3.2

Exported functions

iap_refresh_<WORKGROUP>_session_yaml:
Updates a token in the appropriate .session.yaml by trading in an api key stored in the pass database.

'

# IAP PATH
IAP_PATH="${HOME}/.local/bin/iap/latest/iap"

# Installations
YQ_VERSION="3.3.2"

# Set env vars for commands
DEV_IAP_SESSION_YAML="${HOME}/.iap/.session.dev.yaml"
COLLAB_IAP_SESSION_YAML="${HOME}/.iap/.session.collab.yaml"
COLLAB_DEV_IAP_SESSION_YAML="${HOME}/.iap/.session.collab-dev.yaml"
PROD_IAP_SESSION_YAML="${HOME}/.iap/.session.prod.yaml"

# Set password keys for api keys
IAP_GPG_PASS_KEY_ROOT="iap/api-keys"
DEV_IAP_GPG_PASS_KEY="${IAP_GPG_PASS_KEY_ROOT}/development"
COLLAB_IAP_GPG_PASS_KEY="${IAP_GPG_PASS_KEY_ROOT}/collab"
COLLAB_DEV_IAP_GPG_PASS_KEY="${IAP_GPG_PASS_KEY_ROOT}/collab_dev"
PROD_IAP_GPG_PASS_KEY="${IAP_GPG_PASS_KEY_ROOT}/prod"

# Set workgroup ids
DEV_IAP_WORKGROUP_ID="e4730533-d752-3601-b4b7-8d4d2f6373de"
COLLAB_IAP_WORKGROUP_ID="9c481003-f453-3ff2-bffa-ae153b1ee565"
COLLAB_DEV_IAP_WORKGROUP_ID="971b36d0-5997-3334-9ad7-fe8eb96aee34"
PROD_IAP_WORKGROUP_ID="4d2aae8c-41d3-302e-a814-cdc210e4c38b"

# Set auth url
IAP_DOMAIN="umccr"

##################
# Tiny Functions
##################

# Version sorter

_verlte() {
  [ "$1" = "$(echo -e "$1\n$2" | sort -V | head -n1)" ]
}

_verlt() {
  [ "$1" = "$2" ] && return 1 || verlte "$1" "$2"
}

_check_yq_version() {
  : '
  Check yq is installed.
  Check version
  '
  # Check yq is installed
  (
    if ! yq --version >/dev/null 2>&1; then
      echo "Error: please install yq version 3.3.2 or higher" 1>&2
      return 1
    fi
  )

  # Check yq version is 3.3.2 or higher
  if ! _verlte "${YQ_VERSION}" "$(yq --version |& cut -d' ' -f3)"; then
    echo "Please install yq version 3.3.2 or higher" 1>&2
    return 1
  fi
}

##################
# Primary functions
##################

_iap() {
  : '
  Adds iap to path
  Takes in token env var as IAP_TOKEN
  Extends the iap command with --access-token=token
  Run inside subshell to prevent iap being added to global PATH variable
  Assumes iap binary resides at ~/.local/bin/iap/iap
  Add iap to path - and run with access token
  '
  IAP_ACCESS_TOKEN="${IAP_AUTH_TOKEN}" \
    "${IAP_PATH}" "${@}"
}

_create_iap_token() {
  : '
  Given an api key, create a cli token
  '
  local api_key="$1"
  local workgroup_id="$2"

  # Return the token string
  "${IAP_PATH}" tokens create \
    --api-key="${api_key}" \
    --workgroup-id="${workgroup_id}"
}

_get_api_key() {
  : '
  Given a gpg pass to the api key, key, return value.
  This may ask you for a gpg password
  '

  local pass_key="$1"

  echo "Retrieving key ${pass_key} from gpg pass manager" 1>&2
  pass "${pass_key}"
}

_get_iap_token() {
  : '
  Get the iap token from a session yaml
  Should be used in more explicit commands - like _get_iap_dev_token()
  '
  # Get the yaml file
  local yaml_file="$1"
  local token

  # Check yq is installed
  if ! _check_yq_version; then
    return 1
  fi

  # Check file exists
  if [[ ! -e "${yaml_file}" ]]; then
    echo "Error: ${yaml_file} does not exists" 1>&2
  fi

  # Retrieve token from yaml file
  yq r "${yaml_file}" 'access-token'
}

###########################
# IAP SSO Login
###########################

_iap_sso_login() {
  : '
  Login via auth url
  '
  # Log into iap
  "${IAP_PATH}" login \
    --sso \
    --domain "${IAP_DOMAIN}"

}

###########################
# Token creation management
###########################

_update_session_yaml() {
  : '
  Given a new token and a session path,
  Update a session yaml with the a new token
  '
  local new_token="$1"
  local session_yaml_path="$2"

  # Check yq exists in path and is a high enough version
  if ! _check_yq_version; then
    return 1
  fi

  # Check session yaml exists
  if [[ ! -f "${session_yaml_path}" ]]; then
    echo "Could not update yaml file \"${session_yaml_path}\". It does not exist" 1>&2
  fi

  # Update session yaml inplace
  echo "Updating access token in ${session_yaml_path}" 1>&2
  yq w -i "${session_yaml_path}" "access-token" "${new_token}"
}

_iap_refresh_token_in_session_yaml() {
  : '
  Given a pass-key to an api key and a session yaml
  Retrieve the apikey, create new token and write this to the new session yaml
  '

  # Set input vars
  local api_key_path="$1"
  local session_yaml_path="$2"
  local workgroup_id="$3"

  # Login first via sso.
  echo "Logging into iap via sso" 1>&2
  _iap_sso_login

  # Retrieve api key
  api_key="$(_get_api_key "${api_key_path}")"

  # Create a new iap token
  token="$(_create_iap_token "${api_key}" "${workgroup_id}")"

  # Write the new token to the session yaml
  _update_session_yaml "${token}" "${session_yaml_path}"
}

#####################################################
# Set Workgroup specific tokens in session yaml files
#####################################################

iap_refresh_dev_session_yaml() {
  _iap_refresh_token_in_session_yaml "${DEV_IAP_GPG_PASS_KEY}" "${DEV_IAP_SESSION_YAML}" "${DEV_IAP_WORKGROUP_ID}"
}

iap_refresh_collab_session_yaml() {
  _iap_refresh_token_in_session_yaml "${COLLAB_IAP_GPG_PASS_KEY}" "${COLLAB_IAP_SESSION_YAML}" "${COLLAB_IAP_WORKGROUP_ID}"
}

iap_refresh_collab_dev_session_yaml() {
  _iap_refresh_token_in_session_yaml "${COLLAB_DEV_IAP_GPG_PASS_KEY}" "${COLLAB_DEV_IAP_SESSION_YAML}" "${COLLAB_DEV_IAP_WORKGROUP_ID}"
}

iap_refresh_prod_session_yaml() {
  _iap_refresh_token_in_session_yaml "${PROD_IAP_GPG_PASS_KEY}" "${PROD_IAP_SESSION_YAML}" "${PROD_IAP_WORKGROUP_ID}"
}

################################
# Get Workgroup specific tokens
################################

_get_iap_dev_token() {
  # Get token from yaml
  local token
  token=$(_get_iap_token "${DEV_IAP_SESSION_YAML}")
  # Return token
  echo "${token}"
}

_get_iap_collab_token() {
  # Get token from yaml
  local token
  token=$(_get_iap_token "${COLLAB_IAP_SESSION_YAML}")
  # Return token
  echo "${token}"
}

_get_iap_collab_dev_token() {
  local token
  # Get token from yaml
  token=$(_get_iap_token "${COLLAB_DEV_IAP_SESSION_YAML}")
  # Return token
  echo "${token}"
}

_get_iap_prod_token() {
  local token
  # Get token from yaml
  token=$(_get_iap_token "${PROD_IAP_SESSION_YAML}")
  # Return token
  echo "${token}"
}

#################################
# Workgroup specific IAP Commands
#################################

iap_collab() {
  # Run iap with collab token
  IAP_AUTH_TOKEN="$(_get_iap_collab_token)" _iap "${@}"
}

iap_dev() {
  # Run iap with dev token
  IAP_AUTH_TOKEN="$(_get_iap_dev_token)" _iap "${@}"
}

iap_prod() {
  # Run iap with prod token
  IAP_AUTH_TOKEN="$(_get_iap_prod_token)" _iap "${@}"
}
