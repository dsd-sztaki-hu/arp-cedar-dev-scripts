#!/usr/bin/env bash
#
# Starts the CEDAR microservices for development purposes.
#
# Can be used after successful installation using devinstall.sh
#
# microstart.sh [services to ignore from start]
#

source ./common.sh

ceddev

cedarenv

# ceddev sets it to default value, but we override it with our configured value
export CEDAR_BIOPORTAL_API_KEY=$CEDAR_BIOPORTAL_API_KEY_CONFIGURED

printf "\n+++++ Starting all CEDAR microservices for configuration\n\n"

IGNORRED_SERVICES=""
if [[ ! -z "$@" ]]; then
  # IGNORRED_SERVICES contains services in alphabetic order
  IGNORRED_SERVICES="$@" # `echo "$@" | tr " " "\n" | sort | tr "\n" " " ;echo`
fi

# Collect services except those in $IGNORRED_SERVICES
SERVICES_TO_START="Artifact Group Impex Internals Messaging OpenView Repo Resource Schema Submission Terminology User ValueRecommender Worker"
IFS=' ' read -ra IGNORRED <<< "$IGNORRED_SERVICES"
for i in "${IGNORRED[@]}"; do
  SERVICES_TO_START=${SERVICES_TO_START//${i}/}
done

echo "+++++ Services to start: $SERVICES_TO_START"
echo "+++++ Services ignorred: ""${IGNORRED_SERVICES,,}"

# Make IGNORRED_SERVICES lowercase. startallbut uses lowercase names (just as startall)
( ./startallbut.sh "${IGNORRED_SERVICES}" ) &



# Check for running services 30 times
sleep 5
for i in {1..30}; do
  echo "checkss $SERVICES_TO_START"
  checkss "$SERVICES_TO_START"
  if [[ $WAITING_FOR == "" ]]
  then
    printf "\n+++++ All up and running!\n\n"
    break
  else
    printf "\n+++++ Waiting for: $WAITING_FOR ($i/30)\n\n"
  fi
  sleep 3
done

if [[ ! $WAITING_FOR == "" ]]; then
    printf "\n+++++ Starting all CEDAR microservices failed. Not running: $WAITING_FOR.\n"
    killall java
    exit -1
fi