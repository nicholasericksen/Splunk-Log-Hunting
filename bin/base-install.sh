#!/usr/bin/bash

# Install docker
sudo yum check-update
curl -fsSL https://get.docker.com/ | sh
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# Install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install nginx
sudo yum install epel-release -y
sudo yum install nginx -y

# Generate main ssl cert
#openssl req -x509 -nodes -days 365 -newkey rsa:2048 -batch -keyout /etc/pki/tls/private/main.key -out /etc/pki/tls/certs/main.crt -config /tmp/config/openssl.conf

#cp /tmp/config/nginx.conf /etc/nginx/nginx.conf

sudo systemctl start nginx
sudo systemctl enable nginx


# Install git
yum install git -y

# Disable Selinux
#TODO reduce disable to allow specific permissinos for nginx
setenforce Permissive

# Enable ipv4 forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
systemctl restart network
systemctl restart docker
