# Set the base image to Ubuntu 16.04 and NVIDIA GPU
FROM nvidia/cuda:10.2-devel-ubuntu18.04

# File Author / Maintainer
MAINTAINER Johannes Debler <johannes.debler@curtin.edu.au>

ARG BONITO_VERSION=0.4.0
ARG CONDA_VERSION=py38_4.9.2
ARG CONDA_MD5=122c8c9beb51e124ab32a0fa6426c656

WORKDIR /home

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update && \
    apt-get install --yes \
                        wget \
                        libz-dev \
                        apt-transport-https \
                        git

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -O miniconda.sh && \
    echo "${CONDA_MD5}  miniconda.sh" > miniconda.md5 && \
    if ! md5sum --status -c miniconda.md5; then exit 1; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh miniconda.md5 && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy


RUN pip install ont-bonito==${BONITO_VERSION} && \
    bonito download --models --latest -f && \
    apt-get autoremove --purge --yes && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
