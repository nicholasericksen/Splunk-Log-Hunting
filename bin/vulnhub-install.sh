#!/bin/bash

cd ~

# Clone the vulnerablity hub
git clone https://github.com/vulhub/vulhub.git
cd vulhub

# Select Random Service
rand_dir=$(ls -d */ | sort -R | tail -n 1)

cd $rand_dir

# Select Random CVE
cve_dir=$(ls -d */ | sort -R | tail -n 1)

cd $cve_dir

# Build Vulnerable Image and Run
docker build
docker-compose up -d
