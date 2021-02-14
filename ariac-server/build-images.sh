#!/bin/bash -x
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NOCOLOR='\033[0m'

# Uncoment this line to rebuild without cache
DOCKER_ARGS="--no-cache"

set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "${YELLOW}Build image: ariac-server${NOCOLOR}"

UBUNTU_DISTRO=${1:-bionic}
ROSDISTRO=melodic
case $UBUNTU_DISTRO in
  "bionic")
    ROSDISTRO="melodic"
    ;;

  "focal")
    ROSDISTRO="noetic"
    ;;

  *)
    ROSDISTRO="melodic"
    ;;
esac

BASE_DIMG=${2:-ros:${ROSDISTRO}-ros-base}

DOCKER_ARGS="--no-cache"
USERID=`id -u $USER`
if [[ ${USERID} != 0 ]]; then
  DOCKER_ARGS="--build-arg USERID=${USERID}"
fi

docker build --force-rm ${DOCKER_ARGS} --build-arg BASE_DIMG="${BASE_DIMG}" --build-arg UBUNTU_DISTRO=$UBUNTU_DISTRO --build-arg ROSDISTRO=$ROSDISTRO --tag usnistgov/ariac:server-$UBUNTU_DISTRO $DIR/ariac-server
