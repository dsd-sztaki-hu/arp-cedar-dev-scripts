#!/usr/bin/env -S bash -e
#
# Stops the CEDAR microservices started for development purposes.
#
# Can be used after successful installation using devinstall.sh
#

source ./common.sh

ceddev
stopall