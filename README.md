# ARP specific CEDAR development scripts

These scripts help setting up a development environment for CEDAR.

There are two ways to install CEDAR for trial and development:

https://metadatacenter.readthedocs.io/

The docker installation, while mostly works, is not supported. The development setup in this document is rather inconvenient as you have to install all infra components locally.

The ideal solution for development is to have the infra part run in isolation in docker, while the CEDAR specific microservices run on the development machine atively.

These scripts help setting up this hibrid configuration. For this to work the followin docker installation repos have been cloned and updated to actually work and also to work on M1 macs:

- https://github.com/metadatacenter/cedar-docker-build
- https://github.com/metadatacenter/cedar-docker-deploy

These are our versions we use in these scripts:

- https://github.com/dsd-sztaki-hu/cedar-docker-build
  - https://github.com/dsd-sztaki-hu/cedar-docker-build/tree/arp-intel
  - https://github.com/dsd-sztaki-hu/cedar-docker-build/tree/arp-arm
- https://github.com/dsd-sztaki-hu/cedar-docker-deploy
  - https://github.com/dsd-sztaki-hu/cedar-docker-deploy/tree/arp-intel
  - https://github.com/dsd-sztaki-hu/cedar-docker-deploy/tree/arp-arm

## Infra and microservices installation

Installation happens using the `./devinstall.sh` script.

```
git clone git@github.com:dsd-sztaki-hu/arp-cedar-dev-scripts.git
cd arp-cedar-dev-scripts
./devinstall.sh
```

The script will ask for 3 values:

- CEDAR_DOCKER_HOME: ${HOME}/CEDAR_DOCKER
- CEDAR_HOME: ${HOME}/CEDAR
- PLATFORM: intel or arm

The files necessary for the installation will be downloaded to CEDAR_DOCKER_HOME and CEDAR_HOME and will use the appropriate branch to match the PLATFORM.

At the beginning the script generates some commands that should be placed in your `.bashrc` to easily access the docker and dev env vars and aliases.

The command look somethiong like this:

    # CEDAR Docker related scripts, aliases, environment variables
    export CEDAR_DOCKER_HOME=/the/CEDAR_DOCKER_HOME/you/provided
    alias ceddock="source \${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-1.sh; source \${CEDAR_DOCKER_HOME}/cedar-development/bin/templates/cedar-profile-docker-eval-2.sh"
    
    # CEDAR development related scripts, aliases, environment variables
    export CEDAR_HOME=/the/CEDAR_HOME/you/provided
    alias ceddev="source \${CEDAR_HOME}/cedar-profile-native-develop.sh"

It provides two aliases `ceddock` and `ceddev`.

From this on the script run automatically. Once it finishes you should have both the infra configured and running and also the microservices up and running.

## CEDAR frontend installation

The CEDAR frontend has to be installed following the instruction here:

https://metadatacenter.readthedocs.io/en/latest/install-developer/frontend-overview/

Once it is running you should be able to access the UI at

https://cedar.metadatacenter.orgx/

The HTTPS will not work at this time, because you have to install the self signed certificate for this. Follow the instructions here:

https://metadatacenter.readthedocs.io/en/latest/install-docker-eval/cert-install/

The ca.certs to be installed can be downloaded here:

https://github.com/dsd-sztaki-hu/cedar-docker-deploy/blob/arp-intel/cedar-assets/ca/ca.crt

or can be found locally at ${CEDAR_DOCKER_HOME/cedar-docker-deploy/cedar-assets/ca/ca.certs.

## Users and passwords 

On the CEDAR frontend you can use the following users:

https://metadatacenter.readthedocs.io/en/latest/install-docker-eval/eval-users/

Infra service users:
https://metadatacenter.readthedocs.io/en/latest/install-docker-eval/eval-component-urls/

## Start/stop scripts

Once devinstall.sh has been run successfully you can see the list of services using:

    ceddock # or ceddev
    cedarss

To stop both infra and microservices:

    ./devstop.sh

Stop just infra:

    ./infrastop.sh

Stop just microservcies:

    ./microstop.sh

Sarting up infra + microservices:

    ./devstart.sh

Starting infra and microservices separately in two terminals:

    ./infrastart.sh
    ./microstart.sh
