#!/usr/bin/env bash

: '
Set of functions designed to quickly collect ica session tokens
You are expected to have installed https://github.com/mikefarah/yq globally,
on at least version 4.4.1

Exported functions

ica_refresh_<WORKGROUP>_session_yaml:
Updates a token in the appropriate .session.yaml by trading in an api key stored in the pass database.

'

# ICA PATH
ICA_PATH="${HOME}/.local/bin/ica"

# Installations
YQ_VERSION="4.4.1"

# Set env vars for commands
DEV_ICA_SESSION_YAML="${HOME}/.ica/.session.dev.yaml"
COLLAB_ICA_SESSION_YAML="${HOME}/.ica/.session.collab.yaml"
COLLAB_DEV_ICA_SESSION_YAML="${HOME}/.ica/.session.collab-dev.yaml"
PROD_ICA_SESSION_YAML="${HOME}/.ica/.session.prod.yaml"
PROJ_TEST_SESSION_YAML="${HOME}/.ica/.session.proj-test.yaml"

# Set password keys for api keys
ICA_GPG_PASS_KEY_ROOT="ica/api-keys"
DEV_ICA_GPG_PASS_KEY="${ICA_GPG_PASS_KEY_ROOT}/development"
COLLAB_ICA_GPG_PASS_KEY="${ICA_GPG_PASS_KEY_ROOT}/collab"
COLLAB_DEV_ICA_GPG_PASS_KEY="${ICA_GPG_PASS_KEY_ROOT}/collab_dev"
PROD_ICA_GPG_PASS_KEY="${ICA_GPG_PASS_KEY_ROOT}/prod"
PERSONAL_ICA_GPG_PASS_KEY="${ICA_GPG_PASS_KEY_ROOT}/personal"

# Set workgroup ids
DEV_ICA_WORKGROUP_ID="e4730533-d752-3601-b4b7-8d4d2f6373de"
COLLAB_ICA_WORKGROUP_ID="9c481003-f453-3ff2-bffa-ae153b1ee565"
COLLAB_DEV_ICA_WORKGROUP_ID="971b36d0-5997-3334-9ad7-fe8eb96aee34"
PROD_ICA_WORKGROUP_ID="4d2aae8c-41d3-302e-a814-cdc210e4c38b"
PROJ_TEST_PROJECT_ID="alexis-second-project"

# Set auth url
ICA_DOMAIN="umccr"

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
      echo "Error: please install yq version 4.4.1 or higher" 1>&2
      return 1
    fi
  )

  # Check yq version is 4.4.1 or higher
  if ! _verlte "${YQ_VERSION}" "$(yq --version |& cut -d' ' -f3)"; then
    echo "Please install yq version ${YQ_VERSION} or higher" 1>&2
    return 1
  fi
}

##################
# Primary functions
##################

_ica() {
  : '
  Adds ica to path
  Takes in token env var as ICA_TOKEN
  Extends the ica command with --access-token=token
  Run inside subshell to prevent ica being added to global PATH variable
  Assumes ica binary resides at ~/.local/bin/ica/ica
  Add ica to path - and run with access token
  '
  ICA_ACCESS_TOKEN="${ICA_ACCESS_TOKEN}" \
    "${ICA_PATH}" "${@}"
}

_create_ica_token() {
  : '
  Given an api key, create a cli token
  '
  local api_key="$1"  # Optional - defaults to PERSONAL_ICA_GPG_PASS_KEY
  local workgroup_id="$2"  # Optional

  if [[ "${workgroup_id}" == "" ]]; then
    # Used inside personal context - needed when inside projects
    "${ICA_PATH}" tokens create \
        --api-key="${api_key}"
  else
    # Return the token string
    "${ICA_PATH}" tokens create \
      --api-key="${api_key}" \
      --workgroup-id="${workgroup_id}"
  fi
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

_get_ica_token() {
  : '
  Get the ica token from a session yaml
  Should be used in more explicit commands - like _get_ica_dev_token()
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
  yq eval '.access-token' "${yaml_file}"
}

###########################
# ICA SSO Login
###########################

_ica_sso_login() {
  : '
  Login via auth url
  '
  # Log into ica
  "${ICA_PATH}" login \
    --sso \
    --domain "${ICA_DOMAIN}"

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
  yq eval --inplace ".access-token = \"${new_token}\"" "${session_yaml_path}"
}

_ica_refresh_token_in_session_yaml() {
  : '
  Given a pass-key to an api key and a session yaml
  Retrieve the apikey, create new token and write this to the new session yaml
  '
  # Set input vars
  local api_key_path="$1"
  local session_yaml_path="$2"
  local workgroup_id="$3"  # Optional

  # Login first via sso.
  echo "Logging into ica via sso" 1>&2
  _ica_sso_login

  # Retrieve api key
  api_key="$(_get_api_key "${api_key_path}")"

  # Create a new ica token
  token="$(_create_ica_token "${api_key}" "${workgroup_id}")"

  # Write the new token to the session yaml
  _update_session_yaml "${token}" "${session_yaml_path}"
}

#####################################################
# Set Workgroup specific tokens in session yaml files
#####################################################

ica_refresh_dev_session_yaml() {
  _ica_refresh_token_in_session_yaml "${DEV_ICA_GPG_PASS_KEY}" "${DEV_ICA_SESSION_YAML}" "${DEV_ICA_WORKGROUP_ID}"
}

ica_refresh_collab_session_yaml() {
  _ica_refresh_token_in_session_yaml "${COLLAB_ICA_GPG_PASS_KEY}" "${COLLAB_ICA_SESSION_YAML}" "${COLLAB_ICA_WORKGROUP_ID}"
}

ica_refresh_collab_dev_session_yaml() {
  _ica_refresh_token_in_session_yaml "${COLLAB_DEV_ICA_GPG_PASS_KEY}" "${COLLAB_DEV_ICA_SESSION_YAML}" "${COLLAB_DEV_ICA_WORKGROUP_ID}"
}

ica_refresh_prod_session_yaml() {
  _ica_refresh_token_in_session_yaml "${PROD_ICA_GPG_PASS_KEY}" "${PROD_ICA_SESSION_YAML}" "${PROD_ICA_WORKGROUP_ID}"
}

ica_refresh_proj_test_session_yaml() {
  _ica_refresh_token_in_session_yaml "${PERSONAL_ICA_GPG_PASS_KEY}" "${PROJ_TEST_SESSION_YAML}"
}

################################
# Get Workgroup specific tokens
################################

_get_ica_dev_token() {
  # Get token from yaml
  local token
  token=$(_get_ica_token "${DEV_ICA_SESSION_YAML}")
  # Return token
  echo "${token}"
}

_get_ica_collab_token() {
  # Get token from yaml
  local token
  token=$(_get_ica_token "${COLLAB_ICA_SESSION_YAML}")
  # Return token
  echo "${token}"
}

_get_ica_collab_dev_token() {
  local token
  # Get token from yaml
  token=$(_get_ica_token "${COLLAB_DEV_ICA_SESSION_YAML}")
  # Return token
  echo "${token}"
}

_get_ica_prod_token() {
  local token
  # Get token from yaml
  token=$(_get_ica_token "${PROD_ICA_SESSION_YAML}")
  # Return token
  echo "${token}"
}

_get_ica_proj_test_token() {
  local token
  # Get token from yaml
  token=$(_get_ica_token "${PROJ_TEST_SESSION_YAML}")
  # Return token
  echo "${token}"
}

#################################
# Workgroup specific ICA Commands
#################################

ica_collab() {
  # Run ica with collab token
  ICA_ACCESS_TOKEN="$(_get_ica_collab_token)" _ica "${@}"
}

ica_dev() {
  # Run ica with dev token
  ICA_ACCESS_TOKEN="$(_get_ica_dev_token)" _ica "${@}"
}

ica_prod() {
  # Run ica with prod token
  ICA_ACCESS_TOKEN="$(_get_ica_prod_token)" _ica "${@}"
}

ica_proj_test() {
  # Run ica with proj token
  ICA_ACCESS_TOKEN="$(_get_ica_proj_test_token)" _ica "${@}"
}
