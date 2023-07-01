#!/bin/bash

loc=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${loc}/common.sh

script="get_hash.py"
password=${1:-password}

jail=$(mktemp -d)
sed s/@/${password}/1 ${loc}/${script} > ${jail}/${script}
chmod -R 755 ${jail}

docker run --rm -v ${jail}:${jovyan_home} ${docker_image} python ${script}

rm -rf ${jail}
