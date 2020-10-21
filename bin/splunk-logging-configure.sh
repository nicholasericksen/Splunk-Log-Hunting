#!/bin/bash

curl http://splunkhost/splunk_config.json > /etc/docker/daemon.json

docker plugin install splunk/docker-logging-plugin:latest --alias splunk-logging-plugin --grant-all-permissions
docker plugin enable splunk-logging-plugin

systemctl restart docker
systemctl status docker
