#!/bin/bash

loc=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${loc}/common.sh

docker stop ${docker_name}
#docker rm ${docker_name}
