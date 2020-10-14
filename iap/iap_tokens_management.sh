#!/usr/bin/env bash

: '
Set of functions designed to quickly collect iap session tokens

Functions
_get_iap_token() ->

'

# Set env vars for commands
DEV_IAP_SESSION_YAML="${HOME}/.iap/.session.dev.yaml"
COLLAB_IAP_SESSION_YAML="${HOME}/.iap/.session.collab.yaml"
COLLAB_DEV_IAP_SESSION_YAML="${HOME}/.iap/.session.collab-dev.yaml"
PROD_IAP_SESSION_YAML="${HOME}/.iap/.session.prod.yaml"

##################
# Helper functions
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
  PATH="${HOME}/.local/bin/iap/:${PATH}" \
  IAP_ACCESS_TOKEN="${IAP_AUTH_TOKEN}" \
    iap "${@}"
}

_get_iap_token() {
  : '
  Get the iap token from a session yaml
  Should be used in more explicit commands - like _get_iap_dev_token()
  '
	# Get the yaml file
	local yaml_file="$1"
	local token
	# Check file exists
	if [[ ! -e "${yaml_file}" ]]; then
            echo "Error: ${yaml_file} does not exists" 1>&2
	fi
	# Check yq is installed
	(
	  if ! yq --version >/dev/null 2>&1; then
	      echo "Error: please install yq" 1>&2
	      return 1
	  fi
	)
	# Get IAP token from file
	token=$(cat "${yaml_file}" | yq --raw-output '.["access-token"]')
	# Return token
	echo "${token}"
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
