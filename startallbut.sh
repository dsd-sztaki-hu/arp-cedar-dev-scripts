#!/usr/bin/env bash
clear

shopt -s expand_aliases
source $CEDAR_UTIL_BIN/set-dev-aliases.sh

args="${@}"
args="${args,,}"

echo --------------------------------------------------------------------------------
echo Starting Dropwizard enabled CEDAR microservices except: $args
echo - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


if [[ ! $args =~ group ]]
then
  startgroup
  sleepbetweenstarts
fi

if [[ ! $args =~ messaging ]]
then
  startmessaging
  sleepbetweenstarts
fi

if [[ ! $args =~ repo ]]
then
  startrepo
  sleepbetweenstarts
fi

if [[ ! $args =~ resource ]]
then
  startresource
  sleepbetweenstarts
fi

if [[ ! $args =~ schema ]]
then
  startschema
  sleepbetweenstarts
fi

if [[ ! $args =~ artifact ]]
then
  startartifact
  sleepbetweenstarts
fi

if [[ ! $args =~ terminology ]]
then
  startterminology
  sleepbetweenstarts
fi

if [[ ! $args =~ user ]]
then
  startuser
  sleepbetweenstarts
fi

if [[ ! $args =~ valuerecommender ]]
then
  startvaluerecommender
  sleepbetweenstarts
fi

if [[ ! $args =~ submission ]]
then
  startsubmission
  sleepbetweenstarts
fi

if [[ ! $args =~ worker ]]
then
  startworker
  sleepbetweenstarts
fi

if [[ ! $args =~ openview ]]
then
  startopenview
  sleepbetweenstarts
fi

if [[ ! $args =~ internals ]]
then
  startinternals
  sleepbetweenstarts
fi

if [[ ! $args =~ impex ]]
then
  startimpex
fi


