#!/usr/bin/env bash
#
# Stops the CEDAR infra environment started for development purposes.
#
# Can be used after successful installation using devinstall.sh
#

source ./common.sh

ceddock
stopinfrastructure
