#!/usr/bin/env bash
#
# ARP specific development installation of CEDAR.
#
# It uses a mixed approach: infra is run in docker while the microservices are run natively.
#
# It supports both intel and arm (M1) docker hosts
#

# Make ^C stop the whole script
trap '' INT
trap "exit" INT

# M1 with rosetta: Darwin beep-mbp.local 21.3.0 Darwin Kernel Version 21.3.0: Wed Jan  5 21:37:58 PST 2022; root:xnu-8019.80.24~20/RELEASE_ARM64_T6000 x86_64
# M1 native: Darwin beep-mbp.local 21.3.0 Darwin Kernel Version 21.3.0: Wed Jan  5 21:37:58 PST 2022; root:xnu-8019.80.24~20/RELEASE_ARM64_T6000 arm64
case `uname -a` in
  *arm64*)   PLATFORM=arm ;;
  *ARM64*)   PLATFORM=arm ;;
  *x86_64*)  PLATFORM=intel ;;
esac

CEDAR_DOCKER_HOME=${HOME}/CEDAR_DOCKER
CEDAR_HOME=${HOME}/CEDAR
#CEDAR_DOCKER_HOME=./CEDAR_DOCKER
#CEDAR_HOME=./CEDAR

# If we have previously set the value for above, load them from .env.sh as the defaults
if [[ -f "./.env.sh" ]]; then
  source ./.env.sh
fi

# 1. Determine $CEDAR_DOCKER_HOME

echo -n "CEDAR_DOCKER_HOME ($CEDAR_DOCKER_HOME): "
read CEDAR_DOCKER_HOME_INPUT

if [ ! -z "$CEDAR_DOCKER_HOME_INPUT" ]
then
  CEDAR_DOCKER_HOME=$CEDAR_DOCKER_HOME_INPUT
fi
echo '$CEDAR_DOCKER_HOME': $CEDAR_DOCKER_HOME

# 2.Determine $CEDAR_HOME

echo -n "CEDAR_HOME ($CEDAR_HOME): "
read CEDAR_HOME_INPUT

if [ ! -z "$CEDAR_HOME_INPUT" ]
then
  CEDAR_HOME=$CEDAR_HOME_INPUT
fi
echo '$CEDAR_HOME': $CEDAR_HOME

# Determine platform for the appropriate branch
echo -n "Platform ($PLATFORM) [intel/arm]: "
read PLATFORM_INPUT
if [ ! -z "$PLATFORM_INPUT" ]
then
  PLATFORM=$PLATFORM_INPUT
fi
export BRANCH=arp-$PLATFORM

export CEDAR_DOCKER_HOME=`realpath $CEDAR_DOCKER_HOME`
export CEDAR_HOME=`realpath $CEDAR_HOME`

# Dump the latest env vars to .env.sh so that the next time we run the script, we will have these as defaults
cat > .env.sh << END
export CEDAR_DOCKER_HOME=$CEDAR_DOCKER_HOME
export CEDAR_HOME=$CEDAR_HOME
export PLATFORM=$PLATFORM
export BRANCH=arp-$PLATFORM
END


# Generate .bashrc comands
cat << END


Add these to you .bashrc to get access to aliases and env vars related to running infra services in docker and microservices natively:


------------------------------------------------------------------------------------------------------
# CEDAR Docker related scripts, aliases, environment variables
export CEDAR_DOCKER_HOME=${CEDAR_DOCKER_HOME}
alias ceddock="source \${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-1.sh; source \${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-2.sh"

# CEDAR development related scripts, aliases, environment variables
export CEDAR_HOME=$CEDAR_HOME
alias ceddev="source \${CEDAR_HOME}/cedar-profile-native-develop.sh"
------------------------------------------------------------------------------------------------------



END

echo "Press enter after commands added to .bashrc to continue!"
read PRESSED


./infrainstall.sh

./microinstall.sh
