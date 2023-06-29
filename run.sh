#!/bin/bash

loc=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${loc}/common.sh

work=${loc}/work
mkdir -p ${work}

password=${1:-password}
hash=$(${loc}/hash.sh ${password})

container_id=$(docker \
	run --detach --rm --name ${docker_name} \
	-v ${work}:${jovyan_home}/work \
	-p ${local_port}:${jovyan_port}/tcp \
	-u root \
	-e NB_UID=$(id -u ${USER}) \
	-e NB_GID=$(id -g ${USER}) \
	-e NOTEBOOK_ARGS="--NotebookApp.password=${hash}" \
	${docker_image})

echo ${container_id}
echo "http://localhost:${local_port}/lab"
