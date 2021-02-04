#!/usr/bin/env bash

: '
Commands use to ease outputs and running of iap functions

Exported commands:
* get_ica_aws_sync_command
* run_illumination_<workgroup>
* run_ica_<workgroup>_gui
'

###############
# Miscellaneous
###############

get_ica_aws_sync_command() {
  : '
  Takes in the output from
  ica folders update GDS_PATH --with-access --output-format json
  '
  while [ $# -gt 0 ]; do
      case "$1" in
          --src)
              src="$2"
              shift 1
          ;;
          --dest)
              dest="$2"
              shift 1
          ;;
      esac
      shift
  done

	# Check either src or dest are defined but not both
	# Bash has no xor so we're doing !(x!y || !xy) instead
	if [[ ! ( ( -n "${src}" && -z "${dest}" ) || ( -z "${src}" && -n "${dest}" ) ) ]]; then
	    echo "Define either src or dest with --src and --dest respectively. Mutually exclusive args" 1>&2
      return 1
	fi

	# Use jq to interpret output
	aws_command=$(jq \
                --raw-output \
                  '.objectStoreAccess.awsS3TemporaryUploadCredentials |
                   "AWS_DEFAULT_REGION=\\\"\(.region)\\\" \\
                    AWS_ACCESS_KEY_ID=\\\"\(.access_Key_Id)\\\" \\
                    AWS_SECRET_ACCESS_KEY=\\\"\(.secret_Access_Key)\\\" \\
                    AWS_SESSION_TOKEN=\\\"\(.session_Token)\\\" \\
		                aws s3 sync \\\"$src\\\" \\\"s3://\(.bucketName)/\(.keyPrefix)\\\" \\\"$dest\\\""' /dev/stdin)

	eval echo "${aws_command}" | sed 's/\ \"\"//g'

}

##################
# ILLUMINATION
##################
DEV_PORT="3001"
COLLAB_PORT="3002"
PROD_PORT="3003"

_run_illumination() {
	: '
	Run illumination with these two inputs
	1. Token
	2. Port
	'
	local token="$1"
	local port="$2"
	docker run \
	    -it \
	    --rm \
	    --detach \
	    --env "IAP_TOKEN=${token}" \
	    --env "PORT=${port}" \
	    --publish "${port}:${port}" \
	    "umccr/illumination:latest"
}

run_illumination_dev() {
	# Run illumination with dev user
	# Runs on port 3001
	_run_illumination "$(_get_ica_dev_token)" "${DEV_PORT}"
}

run_illumination_collab() {
	# Run illumination with collab token
	# Runs on port 3002
	_run_illumination "$(_get_ica_collab_token)" "${COLLAB_PORT}"
}

run_illumination_prod() {
  # Run illumination with collab token
	# Runs on port 3002
	_run_illumination "$(_get_ica_prod_token)" "${PROD_PORT}"
}

#########
# ICA GUI
#########
# Set the default
export ICA_BASE_URL="https://aps2.platform.illumina.com"

_run_ica_gui() {
  : '
  Shortcut for running ica_gui
  Single position argument gds_path
  '
  gds_path="$1"
  access_token="$2"
  ica_base_url="$3"

  # Check for base url
  if [[ -z "${ica_base_url}" ]]; then
     ica_base_url="${ICA_BASE_URL}"
  fi

  # Run docker command
  docker run \
    -it \
    --rm \
    --detach \
    --env "DISPLAY=${DISPLAY}" \
    --env "XAUTHORITY=/tmp/.docker.xauth" \
    --env "ICA_ACCESS_TOKEN=${access_token}" \
    --env "ICA_BASE_URL=${ica_base_url}" \
    --volume "/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume "/tmp/.docker.xauth:/tmp/.docker.xauth:rw" \
    umccr/ica_gui:latest \
      --gds-path "$gds_path"
}

run_ica_collab_gui() {
	local gds_path="$1"
	_run_ica_gui "${gds_path}" "$(_get_ica_collab_token)"
}

run_ica_dev_gui() {
	local gds_path="$1"
	_run_ica_gui "${gds_path}" "$(_get_ica_dev_token)"
}

run_ica_prod_gui() {
	local gds_path="$1"
	_run_ica_gui "${gds_path}" "$(_get_ica_prod_token)"
}