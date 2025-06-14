ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

RUN apt update && \
    apt upgrade --assume-yes && \
    ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive && \
    apt install --assume-yes \
        libxrender1 \
        csh \
        fitsverify \
        git \
        python3 \
        python3-pip \
        python3-venv \
        sudo \
        tcsh \
        make \
        gcc \
        htop \
        wget \
        git \
        tar \
        curl \
        time \
        vim \
        awscli

RUN useradd -s /bin/bash -m developer && usermod -aG sudo developer
ENV DEV_HOME=/home/developer

USER developer
WORKDIR /home/developer
RUN python3 -m venv /home/developer/venv
ENV PATH=/home/developer/venv/bin:${PATH}
ENV LD_LIBRARY_PATH=/home/developer/venv/LD_LIBRARY_PATH
COPY requirements.txt ${DEV_HOME}/.
RUN pip install --upgrade pip && \
    pip install -r ${DEV_HOME}/requirements.txt && \
    pip uninstall --yes crds

WORKDIR /home/developer
# CRDS client repo, crds cache folder, crds test cache "default" folder
ADD scripts/ ${DEV_HOME}/scripts
# editable install (for making changes on the fly)
ARG CRDS_REPO=https://github.com/spacetelescope/crds
ARG CRDS_BRANCH=master
RUN git clone --branch $CRDS_BRANCH ${CRDS_REPO}.git
USER root
RUN chown -R developer:developer /home/developer && chmod +x /home/developer/scripts/*
# run test cache setup
USER developer
WORKDIR /home/developer
RUN cd crds && ./install --dev && cd $DEV_HOME
# Set ENVIRONMENT vars
ARG CRDS_CONFIG_OFFSITE=1
ENV CRDS_CONFIG_OFFSITE=$CRDS_CONFIG_OFFSITE
ARG CRDS_READONLY_CACHE=0
ENV CRDS_READONLY_CACHE=$CRDS_READONLY_CACHE
ARG MAST_API_TOKEN
ENV MAST_API_TOKEN=$MAST_API_TOKEN
ARG CRDS_CONTEXT=latest
ENV CRDS_CONTEXT=$CRDS_CONTEXT
ARG CRDS_SERVER_URL=https://hst-crds.stsci.edu
ENV CRDS_SERVER_URL=$CRDS_SERVER_URL

ARG CACHE_SRC=cache_volumes
ENV CACHE_SRC=$CACHE_SRC
ARG CRDS_TEST_ROOT=/home/developer/$CACHE_SRC
ENV CRDS_TEST_ROOT=$CRDS_TEST_ROOT
ARG CRDS_TESTING_CACHE=$CRDS_TEST_ROOT/crds-cache-test
ENV CRDS_TESTING_CACHE=$CRDS_TESTING_CACHE
ARG CRDS_PATH=$CRDS_TEST_ROOT/crds-cache-default-test
ENV CRDS_PATH=$CRDS_PATH

# Get test cache data if requested
ARG DOWNLOAD=1
ARG SYNC=1
RUN scripts/sync-test-cache $CACHE_SRC $DOWNLOAD $SYNC 1
# reset download/sync to zero
ENV DOWNLOAD=0
ENV SYNC=0
CMD /bin/bash
