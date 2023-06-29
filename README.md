# my-jupter-notebook

Building a script to quickly launch a docker instance of a Jupyter notebook server.

## Quickstart

1. Pull the image in to your local docker by running ``./pull.sh``.
1. Run ``./run.sh``
1. Navigate to *http://localhost:8888/*.
1. Login with the preconfigured password "password".

The subdirectory "work" will be created if it does not already exist. In fact this repo currently contains a couple of my sample files, as I was looking for a safe place to keep them. This may move in future.

The docker container will run until you exit the server. When you have finished with the server, use the GUI option

> File -> Shut Down

Then the container will be removed. The sheets you have created will persist in the *work* directory. 

### Options

Only one option so far, which is to supply your own password as a single parameter.

```
./run.sh <password>
```

## Future Options

Add options for

* choosing an alternative image (e.g. the data scientist's workbench).
* choosing an alternative work directory.
* expose the server to an alternative port.

## Design Choices

I used these docker options to make it all work.

### Run once and terminate

``--detach --rm``

### Expose port 8888

``-p 8888:8888/tcp \``

### Volume to store work

``-v <pwd>/work:/home/jovyan/work \``

### Run as the running user

To ensure the server has write access to the work directory.

```
-u root \
-e NB_UID=$(id -u ${USER}) \
-e NB_GID=$(id -g ${USER}) \
```
### Specify password at runtime

``-e NOTEBOOK_ARGS="--NotebookApp.password=${hash}" \``

## Creating The Password Hash

The script ``./hash.sh <password>`` will generate a new hash to give to the server. This is called by the run script as you start it, so a fresh hash is created each time, even if you do not change the password.

### Use a Jupyter container to get a python shell with the right libraries.

```
docker run -it --rm -v jupyter/minimal-notebook:latest python
```

### Python to generate a hash from the python shell

```
from jupyter_server.auth import passwd

passwd()

Enter password:

Verify password:
'argon2:$argon2id$v=19$m=10240,t=10,p=8$LjjLY0QdvlJyRfzyGAQ2PQ$27teXlOPu9Num2rGrlzi1eeKu+TBhQFUkVN2hVuYIMk'
```

### Use the hash within the docker command 

```
-e NOTEBOOK_ARGS="--NotebookApp.password='argon2:$argon2id$v=19$m=10240,t=10,p=8$LjjLY0QdvlJyRfzyGAQ2PQ$27teXlOPu9Num2rGrlzi1eeKu+TBhQFUkVN2hVuYIMk'"
```

