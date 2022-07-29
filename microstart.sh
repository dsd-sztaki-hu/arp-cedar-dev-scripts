#!/usr/bin/env bash
#
# Starts the CEDAR microservices for development purposes.
#
# Can be used after successful installation using devinstall.sh
#

source ./common.sh

ceddev

cedarenv

printf "\n+++++ Starting all CEDAR microservices for configuration\n\n"

( startall ) &

# Check for running services 30 times
sleep 15
for i in {1..30}; do
  checkss "Artifact Group Impex Internals Messaging OpenView Repo Resource Schema Submission Terminology User ValueRecommender Worker"
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