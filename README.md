# CRDS DOCKER TESTING

Running the CRDS client test suite on Docker

Mount your own fork of the CRDS client to run the test suite with live code changes


## Installation and Setup

Steps:

    1. Clone this repo

    2. Copy '.env.template' to a new file named '.env'. Configure settings as needed:
    
        a. use built-in test cache (4.26GB) --> set IMAGE_TAG="latest"

        b. mount your own existing test cache (3.34GB) --> set IMAGE_TAG="slim"

        c. mount existing cache and create a custom image (advanced) --> set IMAGE_TAG to your custom tag

    3. Pull image (`scripts/pull-image`) or Build image (`scripts/build-image`)

    4. Run container: `scripts/run-interactive`

    5. Run test suite


### 1. Clone Repo

Clone this repo into the same parent directory as your CRDS client code so they are at the same directory level, or set the path to your CRDS client code explicitly by editing `.env` and setting `CRDS_ROOT` to the absolute path of your repo folder. (NOTE this is assuming you want to mount the crds repo into the running container, which allows you to make on the fly changes using your IDE).


### 2. Configure Settings

Copy '.env.template' to a new file named '.env'. 
If mounting your own test cache data, move/copy these directories into the "cache_volumes" folder:

    * crds-cache-test
    * crds-cache-default-test

```bash
$ mv crds-cache-default-test/ crds-docker-testing/cache_volumes/.
$ mv crds-cache-test/ crds-docker-testing/cache_volumes/.
```

These (and anything else you place inside "cache_volumes") will be mounted into the container at runtime. You can always re-sync if necessary from inside the container.

Edit `.env` to select an image tag and configure any additional settings:

    * "latest" : built-in test data
    * "slim" : no test data (mount your own)
    * custom tag (if building your own image)

About Image Tag Options

**"latest": built-in test cache ready to go**

If you don't have any test cache data or want to start with a fresh new copy.

**"slim": mount your existing test cache**

If you already have an existing test cache.


### 3. Pull or Build the docker image

The `cache_volumes` folder in this repo will be mounted into the running container. This means anything else you need for testing can be made accessible by placing it in this folder. E.g. for API testing, you can run a jupyter notebook inside the container and view it in a browser over port 8888.


#### Option 1 (simplest): PULL image from Docker Hub

```bash
# Pull image
scripts/pull-image
```

NOTE - you can still mount your own test cache into this image by placing it in "cache_volumes" - it will not be overwritten. The benefit of using "slim" is a smaller download size.


### Option 2 (advanced): BUILD docker image locally

The settings differ for "latest" and "slim" image tags, but keep in mind the scripts that use these default settings are for convenience. Anything can be overridden inside the container by modifying environment variables and also by using crds scripts directly. The key difference is that `latest` includes a built-in crds cache already downloaded, while `slim` does not. 

*2A - Download and sync turned ON* 

At image build time the `sync-test-cache` script will download and sync test cache data similar to `crds/setup_test_cache`. This is turned ON by default for the "latest" image tag. The Sync process can take up to ~21 mins depending on your internet connection.

Default settings for "latest" image_tag:

- cache folder = "/home/developer/crds_cache"
- This folder is created and synced at image build time
- A compressed (.tgz) archive of the cache is created and the folder deleted during image build
- At container runtime, the archive is extracted and used as CRDS_PATH for tests
- The built-in cache can be updated (synced again) with CRDS using the sync-test-cache script from inside a running container, e.g.: `scripts/sync-test-cache crds_cache 0 1`


*2B - Download and sync turned OFF* 

If you already have  `crds-cache-default-test` and `crds-cache-test` installed locally and want to mount these into the container instead of redownloading, resyncing, set DOWNLOAD=0, SYNC=0 then move/copy these directories into the "cache_volumes" folder. If your test cache isn't up to date, you can simply set `export SYNC=1` once you're inside the container and run the sync-test-cache script

```bash
$ vi .env # assuming you've already copied it from .env.template
########## .env ##########
IMAGE_TAG="slim"
########################################
```

Once the settings are configured, build the image:

```bash
$ scripts/build-image
```

Default settings for "slim" image_tag:

- cache folder = "/home/developer/cache_volumes"
- This folder is mounted at container run time
- tests will expect contents of this folder to include crds-cache-test and crds-cache-default-test
- The mounted cache directories can be synced/updated with CRDS using the sync-test-cache script from inside a running container, e.g.: `scripts/sync-test-cache cache_volumes 0 1`


### 3. Run the container

```bash
$ scripts/run-interactive
```

### 4. Run the test suite

```bash
# Run the test suite (from inside running container)
developer@localhost:~$ scripts/runtests
```

Note: you may want to run a subset of tests using pytest markers. To do this, just make sure you have the right environment variables set (i.e. CRDS_TEST_ROOT, CRDS_PATH, etc are set to the desired paths), cd into `crds` and run e.g. `pytest -m roman`


### 5. Troubleshooting

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
