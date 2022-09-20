#!/usr/bin/env -S bash -e
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

export CEDAR_DOCKER_HOME=${HOME}/CEDAR_DOCKER
export CEDAR_HOME=${HOME}/CEDAR
export CEDAR_BIOPORTAL_API_KEY_CONFIGURED="changeme-bbbb-cccc-dddd-eeeeeeeeeeee"
export CEDAR_HOST="metadatacenter.orgx"
#CEDAR_DOCKER_HOME=./CEDAR_DOCKER
#CEDAR_HOME=./CEDAR

# Only load ./common.sh now, because it load .env.sh as well
source ./common.sh

check_node_version

# If we have previously set the value for the above, load them from .env.sh as the defaults
if [[ -f "./.env.sh" ]]; then
  # Remember old values, so that if anything changes in ./.env.sh we remove these dirs and start all over
  OLD_ENV_SH=`cat ./.env.sh`
  OLD_CEDAR_DOCKER_HOME=$CEDAR_DOCKER_HOME
  OLD_CEDAR_HOME=$CEDAR_HOME
fi


echo -n "CEDAR_HOST ($CEDAR_HOST): "
read CEDAR_HOST_INPUT

if [ ! -z "$CEDAR_HOST_INPUT" ]
then
  CEDAR_HOST=$CEDAR_HOST_INPUT
fi
echo 'CEDAR_HOST': $CEDAR_HOST

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

#
echo -n "CEDAR_BIOPORTAL_API_KEY_CONFIGURED ($CEDAR_BIOPORTAL_API_KEY_CONFIGURED): "
read CEDAR_BIOPORTAL_API_KEY_CONFIGURED_INPUT

if [ ! -z "$CEDAR_BIOPORTAL_API_KEY_CONFIGURED_INPUT" ]
then
  CEDAR_BIOPORTAL_API_KEY_CONFIGURED=$CEDAR_BIOPORTAL_API_KEY_CONFIGURED_INPUT
fi
echo '$CEDAR_BIOPORTAL_API_KEY_CONFIGURED': $CEDAR_BIOPORTAL_API_KEY_CONFIGURED


# Determine platform for the appropriate branch
echo -n "Platform ($PLATFORM) [intel/arm]: "
read PLATFORM_INPUT
if [ ! -z "$PLATFORM_INPUT" ]
then
  PLATFORM=$PLATFORM_INPUT
fi
export PLATFORM
export BRANCH=arp-$PLATFORM

export CEDAR_DOCKER_HOME=`realpath $CEDAR_DOCKER_HOME`
export CEDAR_HOME=`realpath $CEDAR_HOME`

# Dump the latest env vars to .env.sh so that the next time we run the script, we will have these as defaults
cat > .env.sh << END
export CEDAR_HOST=$CEDAR_HOST
export CEDAR_DOCKER_HOME=$CEDAR_DOCKER_HOME
export CEDAR_HOME=$CEDAR_HOME
export CEDAR_BIOPORTAL_API_KEY_CONFIGURED=$CEDAR_BIOPORTAL_API_KEY_CONFIGURED
export PLATFORM=$PLATFORM
export BRANCH=arp-$PLATFORM
END

if [ ! -z "$OLD_ENV_SH" ]
then
  NEW_ENV_SH=`cat ./.env.sh`
  if [ "$OLD_ENV_SH" !=  "$NEW_ENV_SH" ]
  then
    printf "\n\n++++ WARNING: .env.sh changed, need to reset installation. This will remove the following directories"
    printf "\n++++ $OLD_CEDAR_DOCKER_HOME"
    printf "\n++++ $OLD_CEDAR_HOME"
    printf "\n++++ Proceed (y/N)? : "
    read YES_OR_NO_INPUT
    if [ -z "$YES_OR_NO_INPUT" ] || [ "$YES_OR_NO_INPUT" != "y" ]
    then
      echo "++++ Directories kept. Running ./devinstall.sh again may result in a wrong installation, so you should remove these directories before rerunning the script"
    else
        rm -rf $OLD_CEDAR_DOCKER_HOME
        rm -rf $OLD_CEDAR_HOME
    fi
  fi
fi

# Clone $CEDAR_DOCKER_HOME and $CEDAR_HOME if not already cloned
if [ ! -d "$CEDAR_DOCKER_HOME" ]
then
  printf "\n\n+++++ Creating $CEDAR_DOCKER_HOME directory\n\n"
  mkdir "$CEDAR_DOCKER_HOME"

  echo "+++++ Cloning cedar-docker-build with branch $BRANCH"
  cd ${CEDAR_DOCKER_HOME}
  git clone git@github.com:dsd-sztaki-hu/cedar-docker-build.git
  cd cedar-docker-build
  git checkout $BRANCH

  echo "+++++ Cloning cedar-docker-deploy with branch $BRANCH"
  cd ${CEDAR_DOCKER_HOME}
  git clone git@github.com:dsd-sztaki-hu/cedar-docker-deploy.git
  cd cedar-docker-deploy
  git checkout $BRANCH

  echo "+++++ Cloning cedar-development"
  cd ${CEDAR_DOCKER_HOME}
  git clone git@github.com:metadatacenter/cedar-development.git
  cd cedar-development
  git checkout master

  printf "\n\n"
else
  echo "$CEDAR_DOCKER_HOME already exists"
fi

if [ ! -d "$CEDAR_HOME" ]
then
  echo "Creating $CEDAR_HOME directory"
  mkdir "$CEDAR_HOME"

  printf "\n\n++++ Cloning microservice repos"
  cd ${CEDAR_HOME}
  git clone https://github.com/metadatacenter/cedar-development
  cd cedar-development
  # Maybe develop branch
  git checkout master
  cd ..
  cp cedar-development/bin/templates/set-env-internal.sh .
  cp cedar-development/bin/templates/set-env-external.sh .
  cp cedar-development/bin/templates/cedar-profile-native-develop.sh .

  echo adsasdadsa $CEDAR_DEVELOP_HOME

  # source it now to have gocedar
  shopt -s expand_aliases
  source ${CEDAR_HOME}/cedar-profile-native-develop.sh
  # gocedar should work here instead of the 'cd' but it doesn't
  cd ${CEDAR_HOME}
  echo ${CEDAR_DEVELOP_HOME}/bin/util/git/git-clone-all.sh
  ${CEDAR_DEVELOP_HOME}/bin/util/git/git-clone-all.sh
  # Maybe develop branch
  source ${CEDAR_HOME}/cedar-profile-native-develop.sh
  # cedargcheckout master
  $CEDAR_UTIL_BIN/git/git-checkout-branch.sh
else
  echo "$CEDAR_HOME already exists"
fi

# Update values in scripts
echo "++++ Setting CEDAR_HOST to $CEDAR_HOST in ${CEDAR_HOME}/set-env-internal.sh"
perl -pi -e 's/export CEDAR_HOST=.*/export CEDAR_HOST='$CEDAR_HOST'/g' ${CEDAR_HOME}/set-env-internal.sh ${CEDAR_HOME}/cedar-development/bin/templates/set-env-internal.sh

echo "++++ Setting CEDAR_HOST to $CEDAR_HOST in ${CEDAR_HOME}/*/.travis.yml"
perl -pi -e 's/  - CEDAR_HOST=.*/  - CEDAR_HOST='$CEDAR_HOST'/g'  ${CEDAR_HOME}/*/.travis.yml

echo "++++ Setting CEDAR_HOST to $CEDAR_HOST in ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/set-env-internal.sh"
perl -pi -e 's/export CEDAR_HOST=.*/export CEDAR_HOST='$CEDAR_HOST'/g' ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/set-env-internal.sh

echo "++++ Updating redirectUris and webOrigins in ${CEDAR_DOCKER_HOME}/cedar-docker-build/cedar-keycloak/config/keycloak-realm.CEDAR.development.20201020.json"
perl -pi -e 's|"redirectUris" : \[ "http://cedar.metadatacenter.orgx/.*|"redirectUris" : [ "http://cedar.metadatacenter.orgx/*", "https://cedar.metadatacenter.orgx/*", "http://cedar.'$CEDAR_HOST'/*", "https://cedar.'$CEDAR_HOST'/*"],|g' ${CEDAR_DOCKER_HOME}/cedar-docker-build/cedar-keycloak/config/keycloak-realm.CEDAR.development.20201020.json
perl -pi -e 's|"webOrigins" : \[ "https://cedar.metadatacenter.orgx.*|"webOrigins" : [ "https://cedar.metadatacenter.orgx", "http://cedar.metadatacenter.orgx", "http://cedar.'$CEDAR_HOST'", "https://cedar.'$CEDAR_HOST'"],|g' ${CEDAR_DOCKER_HOME}/cedar-docker-build/cedar-keycloak/config/keycloak-realm.CEDAR.development.20201020.json

echo "++++ Updating auth-server-url in ${CEDAR_HOME}/cedar-template-editor/app/keycloak.json"
perl -pi -e 's#"auth-server-url":.*#"auth-server-url": "https://auth.'$CEDAR_HOST'/auth/",#g' ${CEDAR_HOME}/cedar-template-editor/app/keycloak.json

# Keycloak is the only service, which calls the resource server via CEDAR_NET_GATEWAY in the
# CEDAR_DOCKER/cedar-docker-build/cedar-keycloak/scripts/tools/listener.cli script.
# Here we make keycloak to call the Resource server running in the host at ${DOCKER_HOST}:9007. For this we edit
# listener.cli
echo "++++ Updating userEventCallbackURL to call Resource server running at ${DOCKER_HOST}:9007 in ${CEDAR_DOCKER_HOME}/cedar-docker-build/cedar-keycloak/scripts/tools/listener.cli"
perl -pi -e 's#\$\{env.CEDAR_NET_GATEWAY\}#'${DOCKER_HOST}'#g' ${CEDAR_DOCKER_HOME}/cedar-docker-build/cedar-keycloak/scripts/tools/listener.cli


# Generate .bashrc commands
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

./guiinstall.sh