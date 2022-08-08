#!/bin/bash -e

shopt -s expand_aliases
source $CEDAR_HOME/cedar-development/bin/util/set-dev-aliases.sh
source $CEDAR_HOME/cedar-profile-native-develop.sh

echo "Please make sure that npm and node are already installed! debian-bootstrap.sh does that on debian."

goeditor
npm -g install gulp
npm install -g @angular/cli

echo "installing dependencies"
goeditor
npm install

echo "starting frontend"
goeditor
gulp
