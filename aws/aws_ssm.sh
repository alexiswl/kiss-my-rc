#!/usr/bin/env bash

: '
SSM Functions to enable easy login to aws nodes running
the ssm agent
'

###########
# FUNCTIONS
###########

ssm() {
  : '
  ssh into the ec2 instance.
  params: instance_id - should start with 'i-'
  '
  local instance_id
  instance_id="$1"
  aws ssm start-session \
    --target "${instance_id}" \
    --document-name AWS-StartInteractiveCommand \
    --parameters command="sudo su - ec2-user"
}


ssm_port() {
  : '
  Log into an ec2 instance and forward the ports
  param: instance_id: starts with 'i-'
  param: remote_port: port on ec2 you wish to forward - should be a number
  param: local_port (optional): port on ec2 you wish to bind the remote port to.
  '
  local instance_id="$1"
  local remote_port="$2"
  local local_port="$3"
  # If local port is not set, set as remote port
  if [[ -z "${local_port}" ]]; then
    local_port="${remote_port}"
  fi
  # Run command
  aws ssm start-session \
    --target "${instance_id}" \
    --document-name "AWS-StartPortForwardingSession" \
    --parameters "{\"portNumber\":[\"${remote_port}\"],\"localPortNumber\":[\"${local_port}\"]}"
}

ssm_run() {
  : '
  Run ssm parameter command
  '

  # Set required parameters
  local command
  local instance_id

  # Get input arguments
  while [ $# -gt 0 ]; do
          case "$1" in
              --command)
                  command="$2"
                  shift 1
              ;;
              --instance-id)
                  instance_id="$2"
                  shift 1
              ;;
          esac
          shift
  done

  # Check --instance-id is defined
  if [[ -z "${instance_id}" ]]; then
    echo "Error, must specify --instance-id for ssm_run function"
    return 1
  fi

  # Switch command to /dev/stdin if not defined in parameter above
  if [[ -z "${command}" ]];then
    command="$(</dev/stdin)"
  fi

  # Now wrap command in su - "ec2-user" -c "${command}"
  # Grossness trigger warning -
  # Escape " by turning into \"
  command="${command}//\"/\\\""
  # Escape \ by turning \ into \\
  # Essentially an internal '"' will become '\\\"'
  command="${command}//\\/\\\\\\"

  # Place command inside 'su - 'ec2-user' -c '<command>'
  # To ensure that the command is created by the right user
  command="su - \\\"ec2-user\\\" -c \\\"${command}\\\""

  # Now send through run shell script command to instance
  command_out="$(aws ssm send-command \
                  --document-name "AWS-RunShellScript" \
                  --targets "Key=InstanceIds,Values=${instance_id}" \
                  --parameters "{\"commands\":[\"${command}\"]}")"

  # Write back command to user
  command_run="$(echo "${command_out}" | {
	               # JQ Command.Parameters.commands
                 jq --raw-output \
	                '.Command.Parameters.commands[0]'
               })"

  echo "Running the following command on \"${instance_id}\"" 1>&2
  echo "${command_run}" 1>&2
}
