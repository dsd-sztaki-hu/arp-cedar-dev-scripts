#!/usr/bin/env bash
#
# Installs the infra in docker. Called from devinstall.sh.
#

source ./common.sh

# We will use these aliases to configure approriate env vars for dev/docker environments
shopt -s expand_aliases
alias ceddock="source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-1.sh; source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-2.sh"
alias ceddev="source ${CEDAR_HOME}/cedar-profile-native-develop.sh"

# Create missing directories
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

if [[ `yes changeit | keytool -list -alias metadatacenter.orgx -keystore ${JAVA_HOME}/lib/security/cacerts` =~ "Certificate fingerprint" ]]; then
  printf "\n\n+++++ Docker configuration's ca.crt already installed in ${JAVA_HOME}/lib/security/cacerts\n\n"
else
  printf "\n\n+++++ Installing docker configuration's ca.crt in ${JAVA_HOME}/lib/security/cacerts\n\n"
  godeploy
  cd cedar-assets/ca/
  # pass: changeit
  printf 'changeit\nyes\n' | keytool -import -alias metadatacenter.orgx -file ./ca.crt -keystore ${JAVA_HOME}/lib/security/cacerts
fi

# to delete the ca.certs:
# keytool -delete -alias metadatacenter.orgx -keystore ${JAVA_HOME}/lib/security/cacerts


ceddock

# This is to have job control
set -m

printf "\n\n+++++ Rebuilding images and resetting volumes\n\n"

# Env vars that affect image creation.  host.docker.internal host name, for example, are used by nginx
# to decide where to proxy requests. Since the microservices run outside the container
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export CEDAR_MICROSERVICE_HOST=host.docker.internal
export CEDAR_KEYCLOAK_HOST=host.docker.internal
export CEDAR_FRONTEND_HOST=host.docker.internal

(cd ${CEDAR_DOCKER_HOME}/cedar-docker-deploy/cedar-infrastructure
docker-compose down -v; \
docker image rm `docker image ls | grep cedar | awk '{print $3}'`; \
source ${CEDAR_DOCKER_DEPLOY}/bin/docker-create-volumes.sh && \
source ${CEDAR_DOCKER_DEPLOY}/bin/docker-copy-certificates.sh)

#printf "\n\n+++++ Starting cedar infrastructure\n\n"
#
#( startinfrastructure ) &
##( goinfrastructure && docker-compose up neo4j) &
#
## Wait a bit for the services to start
#sleep 40
#
## Check for running services 50 times
#for i in {1..30}; do
#  checkss "MongoDB Elasticsearch-REST Elasticsearch-Transport NGINX Keycloak Neo4j Redis-persistent MySQL"
#  if [[ $WAITING_FOR == "" ]]
#  then
#    printf "\n+++++ All up and running!\n\n"
#    break
#  else
#    printf "\n+++++ Waiting for: $WAITING_FOR ($i/30)\n\n"
#  fi
#  sleep 3
#done
#
## Neo4j and Elasticsearch-REST somehow can get stuck and don't start up, in which case one should rerun this script
## and it eventually run OK.
## Or just: goinfrastructure && docker-compose down && docker-compose up
#if [[ ! $WAITING_FOR == "" ]]; then
#    printf "\n+++++ Starting all CEDAR infra services failed. Not running: $WAITING_FOR.\n"
#    printf "+++++ Neo4j and Elasticsearch-REST somehow can get stuck and don't start up, in which case one should rerun this script and it eventually run OK.\n\n"
#    kill %1
#    exit -1
#fi

./infrastart.sh
