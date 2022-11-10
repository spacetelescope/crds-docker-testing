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

**2. Edit USER-CONFIG vars**

Customize the user settings to your crds client repo/fork etc.

```bash
$ vi scripts/user-config

# your github username, e.g. "spacetelescope" (CRDS fork or repo)
export GH_USER="alphasentaurii"
export CRDS_BRANCH="master"
```

*These tell docker what CRDS branch to download at Build time. If you are mounting your repo locally into the container, that will override whatever crds code was downloaded initially when building the image.*

**3. CRDS Test Data Setup**

If you already have  `crds-cache-default-test` and `crds-cache-test` installed locally and want to mount these into the container (instead of redownloading, resyncing the entire test cache):

    - move or copy these into the folder `cache-volumes`
    - set SYNC=0 and DOWNLOAD=0 in `scripts/user-config`

```bash
export DOWNLOAD=0
export SYNC=0
```

*When these are set = 0, the "cache_volumes" folder gets mounted at container run-time. This means you can put any other kind of test data you want to use (i.e. for API testing in a Jupyter notebook) inside "cache_volumes" as well and it will be available in the running container.*

If SYNC=1 and DOWNLOAD=1, at image build time the `config-test-cache` script will download and sync test cache data the same way as running `crds/setup_test_cache`. If you don't have the test cache data, or you just want to start fresh, leave these set = 1.

```bash
# Downloads a fresh copy of the test suite cache and runs the sync script
export DOWNLOAD=1
export SYNC=1
```

*NOTE: You can also run the config-test-cache script manually from inside the running container even if you didn't have it run when you first built the docker image.*

## Build the image

Once the settings are configured to your liking, build the image.

```bash
cd crds-docker-testing
sh scripts/build-image
```


## Run the container

After the image is built, run a container.

```bash
cd crds-docker-testing
sh scripts/run-interactive
```

## Run the CRDS test suite

From inside the running container, run the test suite like you would normally on your local machine.

```bash
cd crds
./runtests
```