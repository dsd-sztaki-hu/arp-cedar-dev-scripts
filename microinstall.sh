#!/usr/bin/env bash -e
#
# Builds and configures the CEDAR microservices. Called from devinstall.sh.
#

# Remember where we started
CURRDIR=`dirname "$0"`
CURRDIR=`realpath $CURRDIR`

source ./common.sh

# We will use these aliases to configure approriate env vars for dev/docker environments
shopt -s expand_aliases
alias ceddock="source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-1.sh; source ${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-2.sh"
alias ceddev="source ${CEDAR_HOME}/cedar-profile-native-develop.sh"

printf "\n+++++ Adding microservice mysql users: cedarMySQLMessagingUser, cedarMySQLLogUser\n\n"

# docker run -it --network cedarnet --rm mysql mysql --host=mysql -uroot --port=3306 --protocol=TCP -pchangeme

docker exec -i mysql mysql -uroot -pchangeme  << END
use mysql;
select user, host from user;
CREATE DATABASE IF NOT EXISTS cedar_messaging;
CREATE USER 'cedarMySQLMessagingUser'@'%' IDENTIFIED BY 'changeme';
GRANT ALL PRIVILEGES ON cedar_messaging.* TO 'cedarMySQLMessagingUser'@'%';
CREATE DATABASE IF NOT EXISTS cedar_log;
CREATE USER 'cedarMySQLLogUser'@'%' IDENTIFIED BY 'changeme';
GRANT ALL PRIVILEGES ON cedar_log.* TO 'cedarMySQLLogUser'@'%';
use mysql;
select user, host from user;
END


printf "\n+++++ Building microservice parent\n\n"

ceddev
goparent
mcit

printf "\n+++++ Building CEDAR microservices\n\n"

createjaxb2workaround
goproject
mcit

# We are in some other dir, so cd back to our script dir
cd $CURRDIR
./microstart.sh

printf "\n+++++ Configuring CEDAR services\n\n"

# Automatically answer with 'yes'
yes yes | cedarat system-reset

