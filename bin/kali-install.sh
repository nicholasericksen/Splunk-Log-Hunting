#!/bin/bash

# Install, Run and Upgrade Kali
docker pull kalilinux/kali-rolling
docker run -t -d --name kali -i kalilinux/kali-rolling
#docker exec -it kali apt-get update && apt-get install metasploit-framework
