# VERSION 0.1
# DOCKER-VERSION  0.7.3
# AUTHOR:         sean <newstein@docker.com>
# DESCRIPTION:    Image with docker-registry project and dependecies
# TO_BUILD:       docker build -rm -t registry .
# TO_RUN:         docker run -p 5000:5000 registry

# Latest Ubuntu LTS
FROM ubuntu:14.04

##sean
##if you are in close network add following proxy env

ENV http_proxy 'http://10.3.0.172:8080'
ENV https_proxy 'http://10.3.0.172:8080'
ENV HTTP_PROXY 'http://10.3.0.172:8080'
ENV HTTPS_PROXY 'http://10.3.0.172:8080'
RUN export http_proxy=$HTTP_PROXY
RUN export https_proxy=$HTTPS_PROXY

## another apt-update site 
RUN sudo rm  -rvf /var/lib/apt/lists/*
RUN sudo sed 's@archive.ubuntu.com@ftp.kaist.ac.kr@' -i /etc/apt/sources.list



# Update
RUN apt-get update \
# Install pip
    && apt-get install -y \
        swig \
        python-pip \
# Install deps for backports.lzma (python2 requires it)
        python-dev \
        python-mysqldb \
        python-rsa \
        libssl-dev \
        liblzma-dev \
        libevent1-dev \
    && rm -rf /var/lib/apt/lists/*

COPY . /private-docker
COPY ./config/boto.cfg /etc/boto.cfg

# Install core
##RUN pip install /private-docker/depends/docker-registry-core
RUN pip install --proxy http://10.3.0.172:8080 /private-docker/depends/docker-registry-core

# Install registry
##RUN pip  install file:///private-docker#egg=private-docker[bugsnag,newrelic,cors]
RUN pip  install --proxy http://10.3.0.172:8080 file:///private-docker#egg=private-docker[bugsnag,newrelic,cors]



RUN patch \
 $(python -c 'import boto; import os; print os.path.dirname(boto.__file__)')/connection.py \
 < /private-docker/contrib/boto_header_patch.diff

ENV DOCKER_REGISTRY_CONFIG /private-docker/config/config_sample.yml
ENV SETTINGS_FLAVOR dev

EXPOSE 5000

##CMD ["docker-registry"]
CMD ["private-docker"]