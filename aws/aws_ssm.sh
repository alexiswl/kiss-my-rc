#!/usr/bin/env bash

: '
SSM Functions to enable easy login to aws nodes running
the ssm agent

* ssm
> Log into a running ec2-instance

* ssm_port
> Port forward to a running ec2-instance

* ssm_run
> Submit a command to an ssm instance
'

###################
# Exported Functions
###################

ssm() {
  : '
  ssh into the ec2 instance.
  params: instance_id - should start with "i-"
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
  param: instance_id: starts with "i-"
  param: remote_port: port on ec2 you wish to forward - should be a number
  param: local_port (optional): port on ec2 you wish to bind the remote port to.
  '
  # Get inputs to function
  local instance_id="$1"
  local remote_port="$2"
  local local_port="$3"
  # Initialise other variables
  local parameter_arg

  # If local port is not set, set as remote port
  if [[ -z "${local_port}" ]]; then
    local_port="${remote_port}"
  fi

  parameter_arg="$(jq --raw-output \
                    --arg "key0" "portNumber" \
                    --arg "value0" "${remote_port}" \
                    --arg "key1" "localPortNumber" \
                    --arg "value1" "${local_port}" \
                    '. | .[$key0]=[$value0] | .[$key1]=[$value1]' <<< '{}')"

  # Run command
  aws ssm start-session \
    --target "${instance_id}" \
    --document-name "AWS-StartPortForwardingSession" \
    --parameters "${parameter_arg}"
}


ssm_run() {
  : '
  Run ssm parameter command
  '

  # Set required parameters
  local command
  local instance_id
  # Other args used throughout
  local parameter_arg
  local command_out
  local command_run
  local command_id

  # Get input arguments
  while [ $# -gt 0 ]; do
          case "$1" in
              --command)
                  command="$2"
                  shift 2
              ;;
              --instance-id)
                  instance_id="$2"
                  shift 2
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

  # Now jq'ise the parameter arguments
  # Credit: https://stackoverflow.com/a/38862221/6946787
  parameter_arg="$(jq --raw-output \
                      --arg "key" "commands" \
                      --arg "command_prefix" "su - \"ec2-user\"" \
                      --arg "command_value" "${command}" \
                      '.[$key]=[$command_prefix + " -c " + "\($command_value | tojson)"]' <<< '{}'
                  )"

  # Now send through run shell script command to instance
  command_out="$(aws ssm send-command \
                  --document-name "AWS-RunShellScript" \
                  --targets "Key=InstanceIds,Values=${instance_id}" \
                  --parameters "${parameter_arg}" \
                )"

  # Write back command to user
  command_run="$(echo "${command_out}" | {
	               # JQ Command.Parameters.commands
                 jq --raw-output \
	                '.Command.Parameters.commands[0]'
               })"

  # Get command ID
  command_id="$(echo "${command_out}" | {
	               # JQ Command.Parameters.commands
                 jq --raw-output \
	                '.Command.CommandId'
               })"


  echo "Running the following command on \"${instance_id}\"" 1>&2
  echo "${command_run}" 1>&2

  echo "Query command status with 'aws ssm list-commands --instance-id=\"${instance_id}\" --command-id=\"${command_id}\"'" 1>&2
}
