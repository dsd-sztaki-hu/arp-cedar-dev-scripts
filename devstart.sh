#!/usr/bin/env bash
#
# Starts the CEDAR development environment (infra + microservices).
#
# Can be used after successful installation using devinstall.sh
#

source ./common.sh

./infrastart.sh
./microstart.sh
cedarss