#!/usr/bin/env bash
#
# Stops the CEDAR development environment (infra + microservices).
#
# Can be used after successful installation using devinstall.sh
#

source ./common.sh

./infrastop.sh
./microstop.sh
