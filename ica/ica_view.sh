#!/usr/bin/env bash

: '
Set of functions for quick viewing gds files without having to download them / store them locally

Usages
ica_view --gds-path gds://path/to/gds/path

Installation requirements:
* docker
* jq 1.5 or higher
* python3 with urllib3 installed

Coming soon:
Removal of python3 urllib requirements -> use docker
Removal of jq requirements -> use docker (need it anyway since we need 1.6 for one component).
'

ica_view() {
  : '
  Uses docker links to view the gds file through its presigned url
  '

  _print_help(){
    echo "
          Usage: ica_view --gds-path gds://volume-name/path-to-file

          Options:
              -g / --gds-path: Path to gds file
              -b / --base-url: ICA base url, https://aps2.platform.illumina.com by default

          Requirements:
            * docker
            * jq
            * python3

          You will need to set the ICA_ACCESS_TOKEN environment variable to run this program.

          The program runs the links binary through docker to
          the gds path via a presigned url.  This can be used on text files and even gzipped files!
          "
  }

  # Inputs
  local gds_path=""
  local base_url=""
  local access_token="${ICA_ACCESS_TOKEN}"

  # Set defaults
  base_url="https://aps2.platform.illumina.com"

  while [ $# -gt 0 ]; do
      case "$1" in
          -g|--gds-path)
              gds_path="$2"
              shift 1
          ;;
          -b|--base-url)
              base_url="$2"
              shift 1
          ;;
          -h|--help)
              _print_help
              return 1
      esac
      shift
  done

  ## Internal functions
  # Get volume
  _get_volume_from_gds_path(){
    : '
    Assumes urllib is available on python3
    '
    local gds_path="$1"

    # Returns the netloc attribute of the gds_path
    python3 -c "from urllib.parse import urlparse; print(urlparse(\"${gds_path}\").netloc)"
  }

  # Get file path
  _get_file_path_from_gds_path(){
    : '
    Assumes urllib is available on python3
    '
    local gds_path="$1"

    # Returns the path attribute of gds_path input
    python3 -c "from urllib.parse import urlparse; print(urlparse(\"${gds_path}\").path)"
  }

  _get_file_id(){
    : '
    Use files list on the file and collect the file id from the single item
    '
    local volume_name="$1"
    local file_path="$2"
    local access_token="$3"
    local base_url="$4"

    # Pipe curl output into jq to collect ID and return
    curl \
      --silent \
      --request GET \
      --header "Authorization: Bearer ${access_token}" \
      "${base_url}/v1/files?volume.name=${volume_name}&path=${file_path}" | \
    jq \
      --raw-output \
      '.items[] | .id'
  }

  _get_presigned_url_from_file_id(){
    : '
    Use files list on the file and collect the file id from the single item
    '
    local file_id="$1"
    local access_token="$2"
    local base_url="$3"

    curl \
      --silent \
      --request GET \
      --header "Authorization: Bearer ${access_token}" \
      "${base_url}/v1/files/${file_id}" | \
    jq \
      --raw-output \
      '.presignedUrl'
  }

  _run_links(){
    : '
    Runs the links container
    '
    local presigned_url="$1"

    # Send through to links
    docker run \
      --rm \
      -it \
      --entrypoint "links" \
      umccr/alpine-links:latest \
      	"${presigned_url}"
  }

  # Break up gds path
  local volume_name
  local file_path
  local file_id
  local presigned_url

  # Checks, ensure access_token is set
  if [[ -z "${access_token}" ]]; then
    echo "Error: Need to set ICA_ACCESS_TOKEN env var" 1>&2
    _print_help
    return 1
  fi

  # Get volume name / get file path from gds path
  volume_name="$(_get_volume_from_gds_path "${gds_path}")"
  file_path="$(_get_file_path_from_gds_path "${gds_path}")"

  # Collect file id
  file_id="$(_get_file_id "${volume_name}" "${file_path}" "${access_token}" "${base_url}")"

  # Collect presigned url
  presigned_url="$(_get_presigned_url_from_file_id "${file_id}" "${access_token}" "${base_url}")"

  # Run links through docker
  _run_links "${presigned_url}"
}

ica_task_view(){
  : '
  Collect task stdout or stderr
  # FIXME needs jq 1.6 need to create a dockerfile
  '

  _print_help(){
    echo "
          Usage: ica_task_view --task-run-id trn.abcdef12345678910 [ --stdout | --stderr ]

          Options:
              -g / --task-run-id: Path to gds file
              -b / --base-url: ICA base url, https://aps2.platform.illumina.com by default
              -o / --stdout: Shows the task stdout
              -e / --stderr: Shows the task stderr

          Requirements:
            * docker
            * jq
            * python3

          You will need to set the ICA_ACCESS_TOKEN environment variable in order to run this program.

          The program runs the links binary through docker to
          the gds path via a presigned url.  This can be used on text files and even gzipped files!
          "
  }

  # Functions
  _get_task_log_file(){
    : '
    Get task stdout
    '

    local task_id="$1"
    local log_file_key="$2"
    local access_token="$3"

    curl \
      --silent \
      --request GET \
      --header "Authorization: Bearer ${access_token}" \
      "${base_url}/v1/tasks/runs/${task_id}" | \
    docker run \
      --rm \
      --interactive \
      --entrypoint jq \
      umccr/alpine-jq:latest \
        --arg "log_file_key" "${log_file_key}" \
        --raw-output \
        '.logs[] | .[$log_file_key]'
  }

  # Initialise variables
  local task_id=""
  local base_url="https://aps2.platform.illumina.com"
  local access_token="${ICA_ACCESS_TOKEN}"
  local print_stdout=0
  local print_stderr=0
  local log_gds_path=""

  # Collect inputs
  while [ $# -gt 0 ]; do
      case "$1" in
          -t|--task-run-id)
              task_id="$2"
              shift 1
          ;;
          -b|--base-url)
              base_url="$2"
              shift 1
          ;;
          -o|--stdout)
              print_stdout="1"
          ;;
          -e|--stderr)
              print_stderr="1"
          ;;
          -h|--help)
              _print_help
              return 1
      esac
      shift
  done


  # Get log gds path
  if [[ "${print_stdout}" == "1" ]]; then
    log_gds_path="$(_get_task_log_file "${task_id}" "stdout" "${access_token}")"
  elif [[ "${print_stderr}" == "1" ]]; then
    log_gds_path="$(_get_task_log_file "${task_id}" "stderr" "${access_token}")"
  else
    echo "Error: Please specify -o/--stdout or -e/stderr to print" 1>&2
    _print_help
    return 1
  fi

    # Checks, ensure access_token is set
  if [[ -z "${access_token}" ]]; then
    echo "Error: Need to set ICA_ACCESS_TOKEN env var" 1>&2
    _print_help
    return 1
  fi

  # Run ica_view
  ICA_ACCESS_TOKEN="${access_token}" ica_view \
     --gds-path "${log_gds_path}" \
     --base-url "${base_url}"
}

# Wrappers
ica_view_dev(){
  ICA_ACCESS_TOKEN="$(_get_ica_dev_token)" \
  ica_view "${@}"
}

ica_view_prod(){
  ICA_ACCESS_TOKEN="$(_get_ica_prod_token)" \
  ica_view "${@}"
}

ica_task_view_dev(){
  ICA_ACCESS_TOKEN="$(_get_ica_dev_token)" \
  ica_task_view "${@}"
}

ica_task_view_prod(){
  ICA_ACCESS_TOKEN="$(_get_ica_prod_token)" \
  ica_task_view "${@}"
}