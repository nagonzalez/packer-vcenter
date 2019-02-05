#!/usr/bin/env bash

set -e
set -x

# vm tools install
sudo yum install \
    open-vm-tools \
    perl \
    -y

# start and enable vm tools service
sudo systemctl restart vmtoolsd
sudo systemctl enable vmtoolsd
