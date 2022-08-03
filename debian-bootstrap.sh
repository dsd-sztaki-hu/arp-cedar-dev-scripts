#!/bin/bash

apt update
echo "intalling docker prerequisites"
apt-get install ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
[ -f /etc/apt/keyrings/docker.gpg ] || curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt update
apt install netcat git docker-ce docker-ce-cli containerd.io docker-compose-plugin nodejs
[ -L /usr/local/bin/docker-compose ] || ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin/
apt install --no-install-recommends npm