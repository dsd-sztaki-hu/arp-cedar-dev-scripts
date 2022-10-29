#!/bin/bash
#
# Custom git-clone-all.sh to clone the repos mainly from  metadatacenter unless we have a custom fork of it.
# First we look up whether the repo https://github.com/dsd-sztaki-hu/<REPO_NAME> exists and clone it. If not, then
# we clone from https://github.com/metadatacenter/<REPO_NAME>
#
echo ---------------------------------------------
echo " Cloning all CEDAR repos"
echo ---------------------------------------------
echo
source $CEDAR_UTIL_BIN/include-repo-list.sh
# https://github.com/metadatacenter/cedar-messaging-server
format="\n\nCloning Git repo status ${GREEN}%-32s${NORMAL} : (%-70s)\n"

function cloneRepo {
  printf "$format" $1 $CEDAR_HOME/$1

  echo "Checking availability of $1 under https://github.com/dsd-sztaki-hu/$1"
  TWO_HUNDRED=`curl -I https://github.com/dsd-sztaki-hu/$1 | head -1 | grep 200`
  if [ ! -z "$TWO_HUNDRED" ]
  then
    echo "Cloning https://github.com/dsd-sztaki-hu/$1"
    git -C "$CEDAR_HOME" clone https://github.com/dsd-sztaki-hu/$1
  else
    echo "Cloning https://github.com/metadatacenter/$1"
    git -C "$CEDAR_HOME" clone https://github.com/metadatacenter/$1
  fi

  git -C "$CEDAR_HOME/$1" status
  git -C "$CEDAR_HOME/$1" status | egrep 'Your branch is up to date with|Your branch is up-to-date with'
  if [ $? == 0 ]; then
    echo "${GREEN}Up-to-date with remote :)${NORMAL}"
  else
    echo "${RED}Something to do here!${NORMAL}"
  fi
}

for i in "${CEDAR_REPOS[@]}"
do
   cloneRepo $i
done
