#!/usr/bin/env bash
#
# Starts the CEDAR infra environment for development purposes.
#
# Can be used after successful installation using devinstall.sh
#
source ./common.sh

ceddock

# This is to have job control
set -m

# Env vars that affect image creation.  host.docker.internal host name, for example, are used by nginx
# to decide where to proxy requests. Since the microservices run outside the container
export DOCKER_DEFAULT_PLATFORM=linux/amd64
export CEDAR_MICROSERVICE_HOST=host.docker.internal
export CEDAR_KEYCLOAK_HOST=host.docker.internal
export CEDAR_FRONTEND_HOST=host.docker.internal

printf "\n\n+++++ Starting cedar infrastructure\n\n"

( startinfrastructure ) &
#( goinfrastructure && docker-compose up neo4j) &

# Wait a bit for the services to start
sleep 40

# Check for running services 50 times
for i in {1..30}; do
  checkss "MongoDB Elasticsearch-REST Elasticsearch-Transport NGINX Keycloak Neo4j Redis-persistent MySQL"
  if [[ $WAITING_FOR == "" ]]
  then
    printf "\n+++++ All up and running!\n\n"
    break
  else
    printf "\n+++++ Waiting for: $WAITING_FOR ($i/30)\n\n"
  fi
  sleep 3
done

# Neo4j and Elasticsearch-REST somehow can get stuck and don't start up, in which case one should rerun this script
# and it eventually run OK.
# Or just: goinfrastructure && docker-compose down && docker-compose up
if [[ ! $WAITING_FOR == "" ]]; then
    printf "\n+++++ Starting all CEDAR infra services failed. Not running: $WAITING_FOR.\n"
    printf "+++++ Neo4j and Elasticsearch-REST somehow can get stuck and don't start up, in which case one should rerun this script and it eventually run OK.\n\n"
    kill %1
    exit -1
fi