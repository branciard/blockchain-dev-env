#!/usr/bin/env bash

set vx
apt-get install -y software-properties-common
add-apt-repository -y ppa:ethereum/ethereum
add-apt-repository -y ppa:ethereum/ethereum-dev
add-apt-repository -y ppa:ethereum/ethereum-qt
# for docker
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# for docker compose
curl -L https://github.com/docker/compose/releases/download/1.21.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
#for yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

apt-get update

apt-get install -y jq
apt-get install -y bc

# need for parity-bridge compile
apt-get install -y pkgconfig

#install build essential
apt-get install -y build-essential openssl libssl-dev libudev-dev

#install some essential : git curl etc ...
apt-get install -y git curl zip unzip wget dstat ntp
service ntp reload

#python base
apt-get install -y python python-pip python-dev

# install node
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install -y nodejs

#install npm
apt-get install -y npm

#docker
apt-get install -y linux-image-extra-$(uname -r)
apt-get install -y linux-image-extra-virtual
apt-get -y install docker-ce
# add vagrant to docker group
usermod -aG docker vagrant


#install last solc AUTO
apt-get install -y solc

#install solc Manual
#wget https://github.com/ethereum/solidity/releases/download/v0.4.23/solc-static-linux
#chmod +x solc-static-linux
#mv solc-static-linux /usr/bin/solc


# install last Geth AUTO
apt-get install -y ethereum

# install last Geth MANUAL
#wget https://dl.google.com/go/go1.11.linux-amd64.tar.gz
#tar -C /usr/local -xzf go1.11.linux-amd64.tar.gz
#export PATH=$PATH:/usr/local/go/bin
#echo 'export PATH=$PATH:/usr/local/go/bin' >>~/.profile
#su - vagrant -c "echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile"
#git clone https://github.com/ethereum/go-ethereum
#cd go-ethereum
#git checkout v1.8.15
#make geth
#chmod +x build/bin/geth
#cp -f build/bin/geth /usr/bin/
#cd -

# install last parity
bash <(curl https://get.parity.io -L)

# install ethkey-cli
#https://github.com/paritytech/parity-ethereum
#cd parity-ethereum/
#cargo build -p ethkey-cli --release
#./target/release/ethkey --help
#cp -f ./target/release/ethkey /usr/bin/
#cd -

# install parity-ethereum workaround from source
#install rust needed for parity - Ethereum build
#curl -sf -L https://static.rust-lang.org/rustup.sh | sh

#Parity Ethereum also requires gcc, g++, libudev-dev, pkg-config, file, make, and cmake packages to be installed.
#apt-get install -y gcc g++ libudev-dev pkg-config file make cmake

# download Parity Ethereum code
#git clone https://github.com/paritytech/parity-ethereum
#cd parity-ethereum
# https://github.com/paritytech/parity-ethereum/releases/tag/v1.11.8
#git checkout v1.11.8
#cargo build --release --features final
#chmod +x target/release/parity
#cp -f target/release/parity /usr/bin/
#cd -

parity --version

#install last truffle
npm install -g truffle@v4.1.14
#install last ganache-cli
npm install -g ganache-cli@6.1.8


#ipfs
wget https://dist.ipfs.io/go-ipfs/v0.4.17/go-ipfs_v0.4.17_linux-amd64.tar.gz
tar xvfz go-ipfs_v0.4.17_linux-amd64.tar.gz
cd go-ipfs
./install.sh
cd -

#for parity bridge
#install yarn
apt-get install yarn
su - vagrant -c "sudo npm i concurrently -g"
#install rust
curl -sf -L https://static.rust-lang.org/rustup.sh | sh
