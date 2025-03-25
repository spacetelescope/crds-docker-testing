# CRDS DOCKER TESTING

Running the CRDS client test suite on Docker

Mount your own fork of the CRDS client to run the test suite with live code changes


## Installation and Setup

Steps:

    1. Clone this repo

    2. Configure settings in `scripts/user-config` as needed:
    
        a. use built-in test cache (4.26GB)

        b. mount your own existing test cache (3.34GB)

    3. Pull or Build image

    4. Run container

    5. Run test suite


### 1. Clone Repo

Clone this repo into the same parent directory as your CRDS client code so they are at the same directory level, or set the path to your CRDS client code explicitly by editing `scripts/user-config`.

```bash
cd /path/to/crds/parentdir/
# feel free to fork this repo instead
git clone https://github.com/spacetelescope/crds-docker-testing
cd crds-docker-testing
```

If your CRDS client code is not in the same parent directory as this repo, set the path to CRDS explicitly and comment out the line that says `source scripts/pathfinder`:

```bash
$ vi scripts/user-config
########## scripts/user-config ##########
# source scripts/pathfinder
export CRDS_ROOT=/abs/path/to/my/crds/client/code
export SHOME=/top/path/to/this/repo
```

### 2. Configure Settings

If mounting your own test cache data, move/copy these directories into the "cache_volumes" folder:

    * crds-cache-test
    * crds-cache-default-test

These (and anything else you place inside "cache_volumes") will be mounted into the container at runtime. You can always re-sync if necessary from inside the container.

```bash
$ mv crds-cache-default-test/ crds-docker-testing/cache_volumes/.
$ mv crds-cache-test/ crds-docker-testing/cache_volumes/.
```

Edit `scripts/user-config` to select an image tag and configure any additional settings:

    * "latest" : built-in test data
    * "slim" : no test data (mount your own)
    * custom tag (if building your own image)

About Image Tag Options

**"latest": built-in test cache ready to go**

If you don't have any test cache data or want to start with a fresh new copy.

**"slim": mount your existing test cache**

If you already have an existing test cache.


```bash
$ vi scripts/user-config

##### image tag #####
# Remove # to select image tag ("latest", "slim", or custom) and comment out the others

export IMAGE_TAG="latest"
# export IMAGE_TAG="slim"

## custom tag if building image (fine to use "latest")
# export IMAGE_TAG=
```

### 3. Pull or Build the docker image

The `cache_volumes` folder in this repo will be mounted into the running container. This means anything else you need for testing can be made accessible by placing it in this folder. E.g. for API testing, you can run a jupyter notebook inside the container and view it in a browser over port 8888.


#### Option 1 (simplest): PULL image from Docker Hub

```bash
# Pull image
scripts/pull-image
```

NOTE - you can still mount your own test cache into this image by placing it in "cache_volumes" - it will not be overwritten. The benefit of using "slim" is a smaller download size.


### Option 2 (advanced): BUILD docker image locally

*2A - Download and sync turned ON* 

At image build time the `config-test-cache` script will try to download and sync test cache data similar to `crds/setup_test_cache`. This is turned ON by default. The Sync process can take up to ~21 mins depending on your internet connection:

```bash
$ vi scripts/user-config

########## scripts/user-config ##########
# tag can be anything you want when building image
export IMAGE_TAG="latest"
export DOWNLOAD=1
export SYNC=1
########################################
```

*2B - Download and sync turned OFF* 

If you already have  `crds-cache-default-test` and `crds-cache-test` installed locally and want to mount these into the container instead of redownloading, resyncing, set DOWNLOAD=0, SYNC=0 then move/copy these directories into the "cache_volumes" folder.

```bash
$ vi scripts/user-config
########## scripts/user-config ##########
# tag can be anything you want when building image
export IMAGE_TAG="slim"
export DOWNLOAD=0
export SYNC=0
########################################
```

Once the settings are configured, build the image:

```bash
$ bash scripts/build-image
```

### 3. Run the container

```bash
$ bash scripts/run-interactive
```

### 4. Run the test suite

```bash
# Run the test suite (from inside running container)
developer@localhost:~$ scripts/runtests
```

If you get "File Not Found" test failures, you may need to set a more recent CRDS context e.g. "latest" or "jwst-edit" before running sync:

```bash
developer@localhost:~$ export CRDS_CONTEXT="jwst_1015.pmap"
```

The `sync-test-cache` script can be run from inside the running container:

```bash
developer@localhost:~$ CACHE_SRC=cache_volumes
developer@localhost:~$ DOWNLOAD=0
developer@localhost:~$ SYNC=1
developer@localhost:~$ scripts/sync-test-cache $CACHE_SRC $DOWNLOAD $SYNC
```
