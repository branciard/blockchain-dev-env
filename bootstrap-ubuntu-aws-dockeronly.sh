#!/usr/bin/env bash

set vx
apt-get install -y software-properties-common
# for docker
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# for docker compose
curl -L https://github.com/docker/compose/releases/download/1.21.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


apt-get update

#install some essential
apt-get install -y ntp
service ntp reload

#docker
apt-get install -y linux-image-extra-$(uname -r)
apt-get install -y linux-image-extra-virtual
apt-get -y install docker-ce
# add ubuntu to docker group
usermod -aG docker ubuntu
