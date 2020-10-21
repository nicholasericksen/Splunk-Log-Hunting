#!/bin/bash

# Install splunk and run
docker pull splunk/splunk:latest
docker run -d -p 8000:8000 -p 8088:8088 -p 8089:8089 -p 9997:9997 --name splunk -e 'SPLUNK_START_ARGS=--accept-license' -e 'SPLUNK_PASSWORD=Password123' splunk/splunk:latest
sleep 180
TOKEN=$(docker exec -it splunk /opt/splunk/bin/splunk http-event-collector create -uri https://localhost:8089 -name general -auth admin:Password123 | tail -n 11 | head -n 1 | cut -f2 -d"=")

cd ~

echo "
{
  \"log-driver\": \"splunk\",
  \"log-opts\": {
    \"splunk-token\": \"${TOKEN}\",
    \"splunk-url\": \"https://splunkhost:8088\",
    \"splunk-insecureskipverify\": \"true\"
  }
}" > /usr/share/nginx/html/splunk_config.json

#python -m SimpleHTTPServer 9099 &> /dev/null & pid=$!

# Give server time to start up
#sleep 780

# request page and print to stdout

# Stop server
#kill "${pid}"

# Copy preconfigured apps over

# Restart splunk container
