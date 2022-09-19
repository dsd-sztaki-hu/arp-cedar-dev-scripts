#!/usr/bin/env -S bash -e
#
# Starts the CEDAR development environment (infra + microservices).
#
# Can be used after successful installation using devinstall.sh
#

source ./common.sh

./infrastart.sh
./microstart.sh "$@"
./guiinstall.sh &
cedarss