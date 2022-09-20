#!/usr/bin/env -S bash -e
#
# Common env vars and function
#

# If we have previously set the value for above, load them from .env.sh as the defaults
if [[ -f "./.env.sh" ]]; then
  source ./.env.sh
fi

# During initial runs of devinstall.sh these aliases are not yet added to .bashrc
# So here we define them. Then if the scripts are run after these are added to .bashrc
# It is no problem, since these must be the same aliases.
shopt -s expand_aliases
alias ceddock="source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-1.sh; source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-2.sh"
alias ceddev="source ${CEDAR_HOME}/cedar-profile-native-develop.sh"

# $1: space separated list of services to check for
function checkss {
  echo "checkss param: $1"
  IFS=" "
  WAITING_FOR=""
  SERVICES=`cedarss`
  for s in $1; do
    if [[ (`echo "$SERVICES" | sed -n "s/\($s \)/\1/p"` =~ "Stopped") ]]; then
      WAITING_FOR="$WAITING_FOR $s"
    fi
  done
}

function check_node_version {
  if [[ ! -z "$1" ]]
  then
    V=$1
  else
    V=12
  fi

  echo "Checking if node version is: $V"
  NODE_VERSION=`node -v`
  REGEX="v$V\."
  if [[ "$NODE_VERSION" =~ $REGEX ]]; then
    echo "Node version OK: $NODE_VERSION"
    echo
  else
    echo "Node version expected: $V, got: $NODE_VERSION"
    exit -1
  fi
}

if [ `uname` = "Linux" ]
then
	DOCKER_HOST=172.17.0.1
else
	DOCKER_HOST=host.docker.internal
fi
