# CRDS DOCKER TESTING

Running the CRDS client test suite on Docker

Mount your own fork of the CRDS client to run the test suite with live code changes

## Installation and Setup

**Clone this repo into the same parent directory as your CRDS client code so they are at the same directory level. Otherwise you'll need to set the path to CRDS code explicitly by editing `crds-docker-testing/scripts/user-config`. The crds code in the pre-built image is from spacetelescope/crds master branch. This gets overwritten by whatever CRDS folder you mount at runtime.**

```bash
cd /path/to/crds/parentdir/
# feel free to fork this repo instead
git clone https://github.com/spacetelescope/crds-docker-testing
cd crds-docker-testing
```

If your CRDS client code is not in the same parent directory as this repo, set the path to CRDS explicitly and comment out the line that says `source scripts/pathfinder`:

```bash
$ cd crds-docker-testing
$ vi scripts/user-config

########## scripts/user-config ##########
# source scripts/pathfinder
export CRDS_ROOT=/abs/path/to/my/crds/client/code
export SHOME=/top/path/to/this/repo
```

**Pull or build the docker image**

PULL:Simple (OPTION 1)
1. Pull image (simplest)
    a. use built-in test cache
    b. mount your own existing test cache
2. Run container
3. Run test suite

BUILD:Advanced (OPTION 2)
1. customize env vars
2. build image (allows customization)
3. run container
3. run test suite

*NOTE: `cache_volumes` will be mounted in the running container. This means anything else you need for testing can be made accessible by placing it in this folder. E.g. for API testing, you can run a jupyter notebook inside the container and view it in a browser over port 8888.*


### Option 1: Pull image from Docker Hub

*Option 1A: use docker image built-in test cache*

```bash
# Pull image
$ docker pull alphasentaurii/crds-docker-testing:latest
```

NOTE - you can still mount your own test cache into this image. The "slim" version is just a smaller download (because it doesn't include the test data).

*Option 1B: if you already have an existing test cache you'd prefer to mount into container*

```bash
# Pull image
$ docker pull alphasentaurii/crds-docker-testing:slim
```

2. (OPTIONAL) Customizations (edit `script/user-config`)

To mount your own test cache data (when using Option B above):

```bash
# crds-cache-test, crds-cache-default-test
# Move/copy these into the "cache_volumes" folder in this repository (to be mounted into container at runtime)
# Download and sync of the test cache is turned off by default, but you can re-sync if necessary from inside the container.
$ mv crds-cache-default-test/ crds-docker-testing/cache_volumes/.
$ mv crds-cache-test/ crds-docker-testing/cache_volumes/.
```


3. Run the container

```bash
# Run the container
$ cd crds-docker-testing
$ bash scripts/run-interactive
```

4. Run the test suite

```bash
# Run the test suite (from inside running container)
developer@localhost:~$ scripts/runtests
```



### Option 2: Build image with custom settings 

**1. Edit USER-CONFIG vars (optional)**

Customize the user settings to your crds client repo/fork etc.

*OPTION 2A) mount existing cache*

If you'd prefer to mount an existing test cache, move these into the "cache_volumes" folder and leave DOWNLOAD=0, SYNC=0 (default).

```bash
$ cd crds-docker-testing
$ vi scripts/user-config
```

If you already have  `crds-cache-default-test` and `crds-cache-test` installed locally and want to mount these into the container instead of redownloading, resyncing, leave DOWNLOAD=0, SYNC=0 (default).

```bash
########## scripts/user-config ##########
export DOWNLOAD=0
export SYNC=0
########################################
```

**NOTE: config-test-cache script can be run from inside the running container even if you didn't use that option when you initially built the docker image.**

*OPTION 2B) DOWNLOAD/SYNC NEW CACHE (~17 mins)*

At image build time the `config-test-cache` script will try to download and sync test cache data similar to `crds/setup_test_cache`.

For this, you'll need to set DOWNLOAD=1, SYNC=1

```bash
########## scripts/user-config ##########
export DOWNLOAD=1
export SYNC=1
########################################
```


**2. Build the Image**

Once the settings are configured to your liking, build the image.

```bash
cd crds-docker-testing
bash scripts/build-image
```


**3. Run the Container**

After the image is built, run a container.

```bash
cd crds-docker-testing
bash scripts/run-interactive
```

**4. Run the Test Suite**

From inside the running container:

```bash
# Run the test suite
developer@localhost:~$ scripts/runtests
```
