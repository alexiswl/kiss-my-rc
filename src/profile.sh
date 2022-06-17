#!/usr/bin/env bash

: '
Kiss-my-rc default template
This file should be sourced by .bashrc
'

###################
# PRE-FLIGHT CHECKS
###################
if [[ -z "${KISS_MY_RC_INSTALL_PATH}" ]]; then
  echo "Unable to load kiss-my-rc modules, please ensure KISS_MY_RC_INSTALL_PATH is set" 1>&2
  return 1
fi

# Export module path to the kiss-my-rc-installation path
export MODULEPATH="${MODULEPATH-}:${KISS_MY_RC_INSTALL_PATH}/modules"

# Ensure modules function exists
if ! type module 1>/dev/null 2>&1; then
  echo "Could not confirm environment-modules are installed on this system. Exiting" 1>&2
  return 1
fi

###############
# LOCAL MODULES
###############

# Local aliases
: '
Various collection of useful aliases

For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/LOCAL_ALIASES__
Uncomment the line below to activate the local aliases module
'
# module load kmr/local/aliases

# Local display settings
: '
Local display settings
* Turns on check-win-size which updates the values of LINES and COLUMNS if the window changes
For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/LOCAL_DISPLAY_SETTINGS__
Uncomment the line below to activate the local display settings module
'
# module load kmr/local/display-settings

# Local direxpand settings
: '
Local direxpand settings
* Bash only
* Set shopt -s direxpand

# module load kmr/local/direxpand-settings

# Local path shortcuts
: '
* Simple go-tos and text finders
* GITHUB_PATH env var is expected to exist for go_to_git shortcut
For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/LOCAL_PATH_SHORTCUTS__
Uncomment the line below to activate the local path shortcuts module
'
# module load kmr/local/path-shortcuts

# Local history settings
: '
Local history settings
* Sets histappend shell option which causes all new history lines to be appended
  * Saves multiple logins overwriting the history
* Sets stty ixon which I dont know what that does just yet

For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/LOCAL_HISTORY_SETTINGS__
Uncomment the line below to activate the local history settings module
'
# module load kmr/local/history-settings

# Local serenity settings
: '
Local serenity settings
* Turns off bell-sound

For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/LOCAL_SERENITY_SETTINGS__
Uncomment the line below to activate the local serenity settings module
'
# module load kmr/local/serenity

# Local extraction shortcuts
: '
Shortcut for extracting various compression algorithm based on file suffix

For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/LOCAL_EXTRACTION_SHORTCUTS__
Uncomment the line below to activate the local extraction shortcuts module
'
# module load kmr/local/extraction-shortcuts

# Local xtrace
: '
Shortcut for adding "set +x" to a bash function when run but also
removing any TOKENS from the console
'
# module load kmr/local/mask-xtrace

###############
# OS-SPECIFIC
###############

### WSL2 ###

# WSL2 display
: '
Uses the network information through route.exe to set the DISPLAY environment variable

For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/WSL2_DISPLAY_ENVIROMENT_VARIABLE__
Uncomment the line below to activate the wsl2-specific display env var
'
#module load kmr/wsl2/set-display-env-var

# WSL2 browser
: '
Set the BROWSER variable to "wslview"

For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/WSL2_BROWSER_ENVIROMENT_VARIABLE__
Uncomment the line below to activate the wsl2-specific browser env var
'
# module load kmr/wsl2/set-browser-env-var

#############
# APP MODULES
#############

# AWS
: '
Requires aws v2 to be installed

For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/AWS_SHORTCUTS__

Uncomment the line below to activate the aws shortcuts module
'
# module load kmr/aws/shortcuts

# Conda
: '
Requires conda to be installed

For more information see: __KISS_MY_RC_GITHUB_REPO_WIKI/CONDA_COMPLETION
'
# module load kmr/conda/autocomplete

