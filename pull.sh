#!/bin/bash

loc=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${loc}/common.sh

docker pull ${docker_image}
