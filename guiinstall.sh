#!/bin/bash

echo "Please make sure that npm and node are already installed!"

npm -g install gulp
npm install -g @angular/cli

echo "installing dependencies"
goeditor
npm install

echo "starting frontend"
goeditor
gulp
