# syntax = docker/dockerfile:1.0-experimental

ARG BASE_IMAGE=debian:bullseye-slim
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
        rsync \
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
        vim

RUN useradd -s /bin/bash -m developer && usermod -aG sudo developer
ENV DEV_HOME=/home/developer

RUN wget --quiet --output-document - http://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfitsio-3.49.tar.gz | tar -xz -C $DEV_HOME && cd $DEV_HOME/cfitsio-3.49 && ./configure --prefix=/usr/local --enable-reentrant --disable-curl && make shared && make install

RUN wget --quiet --output-document - https://heasarc.gsfc.nasa.gov/docs/software/ftools/fitsverify/fitsverify-4.20.tar.gz | tar -xz -C $DEV_HOME && cd $DEV_HOME/fitsverify-4.20 && gcc -o fitsverify ftverify.c fvrf_data.c fvrf_file.c fvrf_head.c fvrf_key.c fvrf_misc.c -DSTANDALONE -lcfitsio && cp fitsverify /usr/local/bin

USER developer
WORKDIR /home/developer
RUN python3 -m venv /home/developer/venv
ENV PATH=/home/developer/venv/bin:${PATH}
ENV LD_LIBRARY_PATH=/home/developer/venv/LD_LIBRARY_PATH

RUN pip install --upgrade pip && \
  pip install \
    wheel \
    psutil~=5.7.2 \
    pysynphot==2.0.0 \
    roman_datamodels \
    stsynphot~=1.1.0 \
    git+https://github.com/spacetelescope/jwst && \
    jupyter \
  pip uninstall --yes crds

WORKDIR /home/developer
# CRDS client repo, crds cache folder, crds test cache "default" folder
ADD scripts/ /home/developer/scripts
# editable install (for making changes on the fly)
ARG CRDS_REPO=https://github.com/spacetelescope/crds
ARG CRDS_BRANCH=master
RUN git clone --branch $CRDS_BRANCH ${CRDS_REPO}.git
USER root
RUN chown -R developer:developer /home/developer && chmod +x /home/developer/scripts/*
# run test cache setup
USER developer
WORKDIR /home/developer
ARG CACHE_SRC=cache_volumes
ARG DOWNLOAD=0
ARG SYNC=0
RUN scripts/config-test-cache $CACHE_SRC $DOWNLOAD $SYNC 
RUN cd crds && ./install && pip install -e .[submission,test,docs,synphot]

ARG MAST_API_TOKEN
ENV MAST_API_TOKEN=${MAST_API_TOKEN}
ARG CRDS_CONTEXT
ENV CRDS_CONTEXT=${CRDS_CONTEXT}

CMD /bin/bash
