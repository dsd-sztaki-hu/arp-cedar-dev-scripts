#!/usr/bin/env bash
#
# Common env vars and function
#

# If we have previously set the value for above, load them from .env.sh as the defaults
if [[ -f "./.env.sh" ]]; then
  source ./.env.sh
fi

export CEDAR_DOCKER_HOME=`realpath $CEDAR_DOCKER_HOME`
export CEDAR_HOME=`realpath $CEDAR_HOME`

# During initial runs of devinstall.sh these aliases are not yet added to .bashrc
# So here we define them. Then if the scripts are run after these are added to .bashrc
# It is no problem, since these must be the same aliases.
shopt -s expand_aliases
alias ceddock="source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-1.sh; source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-2.sh"
alias ceddev="source ${CEDAR_HOME}/cedar-profile-native-develop.sh"

# $1: space separated list of services to check for
function checkss {
  IFS=" "
  WAITING_FOR=""
  SERVICES=`cedarss`
  for s in $1; do
    if [[ (`echo "$SERVICES" | sed -n "s/\($s \)/\1/p"` =~ "Stopped") ]]; then
      WAITING_FOR="$WAITING_FOR $s"
    fi
  done
}
