#!/usr/bin/env -S bash -e
#
# Installs the infra in docker. Called from devinstall.sh.
#

source ./common.sh

# We will use these aliases to configure approriate env vars for dev/docker environments
shopt -s expand_aliases
alias ceddock="source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-1.sh; source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-2.sh"
alias ceddev="source ${CEDAR_HOME}/cedar-profile-native-develop.sh"

# Add *.$CEDAR_HOST hosts to /etc/hosts
ceddev
echo "++++ Adding  *.$CEDAR_HOST hosts to /etc/hosts"
${CEDAR_DEVELOP_HOME}/bin/util/add-hosts.sh

# generate certificates
./gencerts.sh

# Always replace existing ca.crt, because it probably have been regenerated by gencerts.sh
yes changeit | keytool -delete -alias $CEDAR_HOST -keystore ${JAVA_HOME}/lib/security/cacerts || true
if [[ `yes changeit | keytool -list -alias $CEDAR_HOST -keystore ${JAVA_HOME}/lib/security/cacerts` =~ "Certificate fingerprint" ]]; then
  printf "\n\n+++++ Docker configuration's ca.crt already installed in ${JAVA_HOME}/lib/security/cacerts\n\n"
else
  printf "\n\n+++++ Installing docker configuration's ca.crt in ${JAVA_HOME}/lib/security/cacerts\n\n"
  cd $CEDAR_DOCKER_HOME/cedar-docker-deploy/cedar-assets/ca
  # pass: changeit
  printf 'changeit\nyes\n' | keytool -import -alias $CEDAR_HOST -file ./ca.crt -keystore ${JAVA_HOME}/lib/security/cacerts
fi

# to delete the ca.certs:
# keytool -delete -alias metadatacenter.orgx -keystore ${JAVA_HOME}/lib/security/cacerts


ceddock


cd $CURRDIR

# This is to have job control
set -m

printf "\n\n+++++ Rebuilding images and resetting volumes\n\n"

# Env vars that affect image creation.  host.docker.internal host name, for example, are used by nginx
# to decide where to proxy requests. Since the microservices run outside the container
export DOCKER_DEFAULT_PLATFORM=linux/amd64

export CEDAR_MICROSERVICE_HOST=$DOCKER_HOST
export CEDAR_KEYCLOAK_HOST=$DOCKER_HOST
export CEDAR_FRONTEND_HOST=$DOCKER_HOST

(cd ${CEDAR_DOCKER_HOME}/cedar-docker-deploy/cedar-infrastructure
docker-compose down -v; \
CEDAR_IMAGES=`docker image ls | grep cedar | awk '{print $3}'`;
if [ ! -z "$CEDAR_IMAGES" ]; then echo "++++ Removing images: $CEDAR_IMAGES"; docker image rm $CEDAR_IMAGES; fi; \
source ${CEDAR_DOCKER_DEPLOY}/bin/docker-create-network.sh; \
source ${CEDAR_DOCKER_DEPLOY}/bin/docker-create-volumes.sh; \
source ${CEDAR_DOCKER_DEPLOY}/bin/docker-copy-certificates.sh)

goinfrastructure
# Don't use buildkit. This causes problems on M1 for now
export DOCKER_BUILDKIT=0
docker compose build

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

cd $CURRDIR
./infrastart.sh
