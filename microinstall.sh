#!/usr/bin/env bash
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

if [ ! -d "$CEDAR_HOME" ]
then
  echo "Creating $CEDAR_HOME directory"
  mkdir "$CEDAR_HOME"

  printf "\n\n++++ Cloning microservice repos"
  cd ${CEDAR_HOME}
  git clone https://github.com/metadatacenter/cedar-development
  cd cedar-development
  # Maybe develop branch
  git checkout master
  cd ..
  cp cedar-development/bin/templates/set-env-internal.sh .
  cp cedar-development/bin/templates/set-env-external.sh .
  cp cedar-development/bin/templates/cedar-profile-native-develop.sh .

  echo adsasdadsa $CEDAR_DEVELOP_HOME

  # source it now to have gocedar
  shopt -s expand_aliases
  source ${CEDAR_HOME}/cedar-profile-native-develop.sh
  # gocedar should work here instead of the 'cd' but it doesn't
  cd ${CEDAR_HOME}
  echo ${CEDAR_DEVELOP_HOME}/bin/util/git/git-clone-all.sh
  ${CEDAR_DEVELOP_HOME}/bin/util/git/git-clone-all.sh
  # Maybe develop branch
  cedargcheckout master
else
  echo "$CEDAR_HOME already exists"
fi

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

