#!/usr/bin/env bash

set -e
set -x

# base packages
sudo yum install \
    epel-release \
    tree \
    yum-utils \
    -y
