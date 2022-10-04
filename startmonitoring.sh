#!/usr/bin/env -S bash -e
#
# Starts the monitoring tools (kibana, phpmyadmin, redis-commander and the CEDAR admin tool)
#

./common.sh
source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-1.sh
source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-2.sh

cd ${CEDAR_DOCKER_HOME}/cedar-docker-build

# These images needed to be built for the admin-tool to work
cd cedar-java
docker image build --tag metadatacenter/cedar-java:$CEDAR_VERSION .

cd ../cedar-microservice
docker image build --tag metadatacenter/cedar-microservice:$CEDAR_VERSION .

# Now run everything in docker
cd $CEDAR_DOCKER_DEPLOY/cedar-monitoring
docker-compose up
