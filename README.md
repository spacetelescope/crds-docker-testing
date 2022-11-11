# CRDS DOCKER TESTING

Running the CRDS client test suite on Docker

Mount your own fork of the CRDS client to run the test suite with live code changes

## Installation and Setup

**1. Clone this repo into the same parent directory as your CRDS client code so they are at the same directory level**

```bash
cd /path/to/crds/parentdir/
# feel free to fork this repo instead
git clone https://github.com/spacetelescope/crds-docker-testing
cd crds-docker-testing
```


### Option 1: Pull image and run container

Pull existing image from Docker Hub, set custom run configs, then run the container.

*Note: if you already have an existing test cache, it's highly recommended that you use OPTION 1A below, since running the test sync from scratch can take a very long time.*

```bash
docker pull alphasentaurii/crds-docker-testing:latest

# OPTION 1A: use existing crds-cache-test and crds-cache-default-test
# Move/copy these into "cache_volumes" (will be mounted into container at runtime)
# Download and sync of the test cache is turned off by default.
mv crds-cache-default-test/ crds-docker-testing/cache_volumes/.
mv crds-cache-test/ crds-docker-testing/cache_volumes/.


# OPTION B: fresh install and sync of test cache data
# Edit scripts/user-config 
cd crds-docker-testing
vi scripts/user-config
########## scripts/user-config ##########
export DOWNLOAD=1
export SYNC=1
########################################

# Run the container
bash scripts/run-interactive

## Run the test suite (from inside running container):
cd crds
./runtests
```



### Option 2: Build image with custom settings 

**2. Edit USER-CONFIG vars (optional)**

Customize the user settings to your crds client repo/fork etc.

```bash
$ vi scripts/user-config
```


**CRDS Test Data Setup**

**Option 2a)** If you already have  `crds-cache-default-test` and `crds-cache-test` installed locally and want to mount these into the container (instead of redownloading, resyncing the entire test cache):

    - move or copy these into the folder `cache-volumes`
    - set SYNC=0 and DOWNLOAD=0 in `scripts/user-config`

```bash
export DOWNLOAD=0
export SYNC=0
```

*When these are set = 0, the "cache_volumes" folder gets mounted at container run-time. This means you can put any other kind of test data you want to use (i.e. for API testing in a Jupyter notebook) inside "cache_volumes" as well and it will be available in the running container.*

**Option 2b)** If SYNC=1 and DOWNLOAD=1, at image build time the `config-test-cache` script will try to download and sync test cache data the same way as running `crds/setup_test_cache`. If you don't have the test cache data, or you just want to start fresh, set these = 1.

*NOTE: You can also run the config-test-cache script manually from inside the running container even if you didn't have it run when you first built the docker image.*

```bash
# Downloads a fresh copy of the test suite cache and runs the sync script
export DOWNLOAD=1
export SYNC=1
```

## Build the image

Once the settings are configured to your liking, build the image.

```bash
cd crds-docker-testing
bash scripts/build-image
```


## Run the container

After the image is built, run a container.

```bash
cd crds-docker-testing
bash scripts/run-interactive
```

## Run the CRDS test suite

From inside the running container:

```bash
# Run the test suite
developer@localhost:~$ scripts/runtests
```