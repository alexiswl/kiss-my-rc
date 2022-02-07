#!/usr/bin/env bash

set -euo pipefail

: '
1. Checks user has all required pre-requisites
2. Asks user to install preferred profile (or use the -p parameter)
3. Install items ~/.kiss-my-rc
'

help_message="Usage: install.sh [ -b | --batch ]
Installs kiss-my-rc into users home directory and bashrc / zshrc.

Options:
-b / --batch: Batch mode, do not prompt user, just inject kiss-my-rc into rc file.

Requirements:

You should have the following applications installed before continuing

* module
* bash v4+

Example:
bash install.sh
"

###########
# FUNCTIONS
###########


echo_stderr() {
  echo "$@" 1>&2
}

print_help() {
  echo_stderr "${help_message}"
}

check_readlink_program() {
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    readlink_program="greadlink"
  else
    readlink_program="readlink"
  fi

  if ! type "${readlink_program}" 1>/dev/null; then
      if [[ "${readlink_program}" == "greadlink" ]]; then
        echo_stderr "On a mac but 'greadlink' not found"
        echo_stderr "Please run 'brew install coreutils' and then re-run this script"
        return 1
      else
        echo_stderr "readlink not installed. Please install before continuing"
      fi
  fi
}

binaries_check(){
  : '
  Check each of the required binaries are available
  '
  if ! (type module 1>/dev/null 2>&1); then
    return 1
  fi
}

get_user_shell(){
  : '
  Quick "one-liner" to get user shell
  '
  # Quick "one liner" to get 'bash' or 'zsh'
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    basename "$(finger "${USER}" | grep 'Shell:*' | cut -f3 -d ":")"
  else
    basename "$(awk -F: -v user="$USER" '$1 == user {print $NF}' /etc/passwd)"
  fi
}

get_this_path() {
  : '
  Mac users use greadlink over readlink
  Return the directory of where this install.sh file is located
  '
  local this_dir

  # darwin is for mac, else linux
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    readlink_program="greadlink"
  else
    readlink_program="readlink"
  fi

  # Get directory name of the install.sh file
  this_dir="$(dirname "$("${readlink_program}" -f "${0}")")"

  # Return directory name
  echo "${this_dir}"
}


#########
# GLOBALS
#########
KISS_MY_RC_INSTALL_PATH="${HOME}/.kiss-my-rc"

#########
# CHECKS
#########
if ! check_readlink_program; then
  echo_stderr "ERROR: Failed installation at readlink check stage"
  print_help
  exit 1
fi

if ! binaries_check; then
  echo_stderr "ERROR: Failed installation at the binaries check stage. Please check the requirements highlighted in usage."
  print_help
  exit 1
fi

user_shell="$(get_user_shell)"

# Check bash version
if [[ "${user_shell}" == "bash" ]]; then
  echo_stderr "Checking bash version"
  if [[ "$( "${SHELL}" -c "echo \"\${BASH_VERSION}\" 2>/dev/null" | cut -d'.' -f1)" -lt "4" ]]; then
    echo_stderr "Please upgrade to bash version 4 or higher, if you are running MacOS then please run the following commands"
    echo_stderr "brew install bash"
    echo_stderr "sudo bash -c \"echo \$(brew --prefix)/bin/bash >> /etc/shells\""
    echo_stderr "chsh -s \$(brew --prefix)/bin/bash"
    exit 1
  fi
fi

# Checking bash-completion is installed (for bash users only)
if [[ "${user_shell}" == "bash" ]]; then
  if ! ("${SHELL}" -lic "type _init_completion 1>/dev/null 2>&1" 2>/dev/null ); then
    echo_stderr "Could not find the command '_init_completion' which is necessary for auto-completion scripts"
    echo_stderr "If you are running on MacOS, please run the following command:"
    echo_stderr "brew install bash-completion@2 --HEAD"
    echo_stderr "Then add the following lines to ${HOME}/.bash_profile"
    echo_stderr "#######BASH COMPLETION######"
    echo_stderr "[[ -r \"\$(brew --prefix)/etc/profile.d/bash_completion.sh\" ]] && . \"\$(brew --prefix)/etc/profile.d/bash_completion.sh\""
    echo_stderr "############################"
    exit 1
  fi
fi

# Check bash version for macos users (even if they're not using bash as their shell)
if [[ "${OSTYPE}" == "darwin"* ]]; then
    echo_stderr "Checking env bash version"
    if [[ "$(bash -c "echo \${BASH_VERSION}" | cut -d'.' -f1)" -le "4" ]]; then
      echo_stderr "ERROR: Please install bash version 4 or higher (even if you're running zsh as your default shell)"
      echo_stderr "ERROR: Please run 'brew install bash'"
      exit 1
  fi
fi

##############
# USER ARGS
##############

# Default args
batch="false"

# Get args from command line
while [ $# -gt 0 ]; do
  case "$1" in
    -b | --batch)
      batch="true"
      ;;
    -h | --help)
      print_help
      exit 0
      ;;
  esac
  shift 1
done

############
# COPY FILES
############

# Let's first create the kiss-my-rc installation directory
# And also copy over elements and modules
mkdir -p \
  "${KISS_MY_RC_INSTALL_PATH}" \
  "${KISS_MY_RC_INSTALL_PATH}/elements/" \
  "${KISS_MY_RC_INSTALL_PATH}/modules/"

cp -r "$(get_this_path)/elements/." "${KISS_MY_RC_INSTALL_PATH}/elements/"
cp -r "$(get_this_path)/modules/." "${KISS_MY_RC_INSTALL_PATH}/modules/"

# Create the profile section
if [[ ! -f "${KISS_MY_RC_INSTALL_PATH}/profile.sh" ]]; then
  # Copy over the profile if there isn't an existing one
  cp "$(get_this_path)/profile.sh" "${KISS_MY_RC_INSTALL_PATH}/profile.sh"
  cp "$(get_this_path)/profile.sh" "${KISS_MY_RC_INSTALL_PATH}/profile.sh"
else
  echo "File ${KISS_MY_RC_INSTALL_PATH}/profile already exists. Not overwriting" 1>&2
  echo "Please copy over $(get_this_path)/profile.sh to ${KISS_MY_RC_INSTALL_PATH}/profile.sh as you wish" 1>&2
fi

user_response=""

while :
do
  # Check if batch selected, skip if so
  if [[ "${batch}" == "true" ]]; then
    break
  fi

  # Prompt user to ask if they would like their bashrc
  read -p "Would you like to add kiss-my-rc to your ${HOME}/.${user_shell}rc file? (y/n): " user_response

  # Check user response
  if [[ "${user_response}" == "n" ]]; then
    echo "kiss-my-rc not added to your ${HOME}/.${user_shell}rc file" 1>&2
    exit
  elif [[ "${user_response}" == "y" ]]; then
    break
  else
    echo "Please answer either 'y' or 'n'" 1>&2
  fi

done

# Adding the following section to shell file if it doesn't exist already
if ! grep -q '# >>> kiss-my-rc >>>' "${HOME}/.${user_shell}rc"; then
  {
    echo ""
    echo "# >>> kiss-my-rc >>>"
    echo "# Kiss my rc installation path"
    echo "export KISS_MY_RC_INSTALL_PATH="\$HOME/.kiss-my-rc""
    echo "if [[ -f "\$HOME/.kiss-my-rc/profile" ]]; then"
    echo "  source "\$HOME/.kiss-my-rc/profile""
    echo "fi"
    echo "# <<< kiss-my-rc <<<"
    echo ""
  } >> "${HOME}/.${user_shell}rc"
fi

