#!/bin/bash

##
# Get common variables and functions.
loc=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
. ${loc}/common.sh

##
# Options Parsing
password="password"
work=${loc}/work
ARGS=$(getopt -o d:w:W --long directory:,pwd:,prompt -- "$@")
if [ $? -ne 0 ]
then
	exit 1
fi
eval set -- "${ARGS}"
while true
do
    case $1 in
        -w|--password) shift; password=$1;;
        -W|--prompt) read -s -p "Password: " password; echo;;
		-d|--directory) shift; work=$1;;
        --) shift; break;;
        *) echo "Unknown option: ${1}"; exit 1;;
    esac
    shift
done

##
# Cleanup on exit
cleanup(){
	rm -rf ${jaildir}
}

##
# Set up working area
mkdir -p ${work}
work=$(readlink -f ${work})

##
# Hash the password
jaildir=$(mktemp -d)
trap cleanup EXIT
sed s/@/${password}/1 ${loc}/${hash_script} > ${jaildir}/${hash_script}
chmod -R 755 ${jaildir}
hash=$(docker run --rm -v ${jaildir}:${jovyan_home} ${docker_image} python ${hash_script})

##
# Start the container
container_id=$(docker \
	run --detach --rm --name ${docker_name} \
	-v ${work}:${jovyan_home}/work \
	-p ${local_port}:${jovyan_port}/tcp \
	-u root \
	-e NB_UID=$(id -u ${USER}) \
	-e NB_GID=$(id -g ${USER}) \
	-e NOTEBOOK_ARGS="--NotebookApp.password=${hash}" \
	${docker_image})

echo "Container ID: ${container_id}"
echo "Notebook URL: http://localhost:${local_port}/lab"
