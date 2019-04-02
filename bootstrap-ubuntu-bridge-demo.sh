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


#install build essential
apt-get install -y build-essential 


#install some essential 
apt-get install -y git curl 

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


#0) create a eth wallet to play
mkdir -p /home/vagrant/dapps
cd /home/vagrant/dapps
sudo npm -g install iexec@v3.0.23
iexec --version

rm -f wallet.json
iexec wallet create --unencrypted

cat wallet.json

export ADMIN_PRIVATE_KEY=$(cat wallet.json | grep privateKey | cut -d ":" -f2 | cut -d "," -f1 | sed 's/\"//g' | sed 's/ //g' | cut  -c3-)
export ADMIN_ADDRESS=$(cat wallet.json | grep address | cut -d ":" -f2 | cut -d "," -f1 | sed 's/\"//g' | sed 's/ //g')


#echo $ADMIN_PRIVATE_KEY
echo "ADMIN_ADDRESS is : $ADMIN_ADDRESS" 


#1 ) define network ids

export NETWORK_ID_HOME=0x11 
echo "NETWORK_ID_HOME is : $NETWORK_ID_HOME" 
export NETWORK_ID_FOREIGN=0x12
echo "NETWORK_ID_FOREIGN is : $NETWORK_ID_FOREIGN" 

#2 ) bootstrap HOME chain

cd /home/vagrant/dapps

rm -rf parity-deploy
rm -rf parity-deploy-home-chain

git clone https://github.com/iExecBlockchainComputing/parity-deploy.git

mv parity-deploy parity-deploy-home-chain

cd parity-deploy-home-chain

git checkout fix-chain-name

#wait PR (https://github.com/paritytech/parity-deploy/pull/109)

sudo ./parity-deploy.sh --config aura --name HOME-CHAIN --nodes 1 --entrypoint "/bin/parity" --release v2.3.8 --expose

# update rich wallet 
sed -i "s/0x00Ea169ce7e0992960D3BdE6F5D539C955316432/`echo $ADMIN_ADDRESS`/g" deployment/chain/spec.json

# update network id
sed -i "s/\"networkID\" : \"0x11\"/\"networkID\" : \"`echo $NETWORK_ID_HOME`\"/g" deployment/chain/spec.json

# update force-sealing
sed -i "s/d \/home\/parity\/data/d \/home\/parity\/data --force-sealing/g" docker-compose.yml

# update host name 
sed -i "s/host1/host-home-chain/g" docker-compose.yml
sed -i "s/host1/host-home-chain/g" deployment/chain/reserved_peers

echo "start home-chain ..."
docker-compose up -d

#3 ) bootstrap FOREIGN chain

cd /home/vagrant/dapps

rm -rf parity-deploy
rm -rf parity-deploy-foreign-chain

git clone https://github.com/iExecBlockchainComputing/parity-deploy.git

mv parity-deploy parity-deploy-foreign-chain
cd parity-deploy-foreign-chain
git checkout fix-chain-name

sudo ./parity-deploy.sh --config aura --name FOREIGN-CHAIN --nodes 1 --entrypoint "/bin/parity" --release v2.3.8 --expose

# update rich wallet 
sed -i "s/0x00Ea169ce7e0992960D3BdE6F5D539C955316432/`echo $ADMIN_ADDRESS`/g" deployment/chain/spec.json

# update network id
sed -i "s/\"networkID\" : \"0x11\"/\"networkID\" : \"`echo $NETWORK_ID_FOREIGN`\"/g" deployment/chain/spec.json

# update force-sealing

sed -i "s/d \/home\/parity\/data/d \/home\/parity\/data --force-sealing/g" docker-compose.yml

# update host name 
sed -i "s/host1/host-foreign-chain/g" docker-compose.yml
sed -i "s/host1/host-foreign-chain/g" deployment/chain/reserved_peers

# change port for no conflict 
sed -i "s/- 8080/- 9080/g" docker-compose.yml
sed -i "s/- 8180/- 9180/g" docker-compose.yml
sed -i "s/- 8545/- 9545/g" docker-compose.yml
sed -i "s/- 8546/- 9546/g" docker-compose.yml
sed -i "s/- 30303/- 40303/g" docker-compose.yml
sed -i "s/30303/40303/g" deployment/chain/reserved_peers

echo "start foreign-chain ..."
docker-compose up -d


#4 ) deploy ERC20 contract (use RLC iExec contract stack)

git clone -b v3.0.26 https://github.com/iExecBlockchainComputing/PoCo.git

cd /home/vagrant/dapps

git clone -b v3.0.26 https://github.com/iExecBlockchainComputing/PoCo.git
rm -rf PoCo-foreign-chain
rm -rf PoCo-home-chain
cp -rf PoCo PoCo-foreign-chain
cp -rf PoCo PoCo-home-chain
rm -rf PoCo

cd  /home/vagrant/dapps/PoCo-foreign-chain
sudo npm i
sudo npm install truffle-hdwallet-provider@1.0.0-web3one.3
cp truffle.js truffle.ori
curl https://raw.githubusercontent.com/branciard/blockchain-dev-env/master/truffle.tmpl -o truffle.tmpl
sed "s/__PRIVATE_KEY__/\"${ADMIN_PRIVATE_KEY}\"/g" truffle.tmpl > truffle.js
echo "launch truffle migrate"
./node_modules/.bin/truffle --version
rm -rf build
rm -rf truffle.log
./node_modules/.bin/truffle migrate --network localForeignChain | tee -a "truffle.log" 

if [ $? -eq 0 ]
then
  echo "truffle migrate success!"
else
  echo "truffle migrate FAILED !"
  exit 1
fi
echo "get RLC contract from truffle.log "
export RlcAddressForeign=$(cat truffle.log | grep "RLC deployed at address:" | cut -d ":" -f2 | sed 's/ //g')
export IexecHubAddressForeign=$(cat truffle.log | grep "IexecHub deployed at address:" | cut -d ":" -f2 | sed 's/ //g')

cd  /home/vagrant/dapps/PoCo-home-chain
sudo npm i
sudo npm install truffle-hdwallet-provider@1.0.0-web3one.3
cp truffle.js truffle.ori
curl https://raw.githubusercontent.com/branciard/blockchain-dev-env/master/truffle.tmpl -o truffle.tmpl
sed "s/__PRIVATE_KEY__/\"${ADMIN_PRIVATE_KEY}\"/g" truffle.tmpl > truffle.js
echo "launch truffle migrate"
./node_modules/.bin/truffle --version
rm -rf build
rm -rf truffle.log
./node_modules/.bin/truffle migrate --network localHomeChain | tee -a "truffle.log" 

if [ $? -eq 0 ]
then
  echo "truffle migrate success!"
else
  echo "truffle migrate FAILED !"
  exit 1
fi
echo "get RLC contract from truffle.log "
export RlcAddressHome=$(cat truffle.log | grep "RLC deployed at address:" | cut -d ":" -f2 | sed 's/ //g')
export IexecHubAddressHome=$(cat truffle.log | grep "IexecHub deployed at address:" | cut -d ":" -f2 | sed 's/ //g')


cd  /home/vagrant/dapps
echo "RlcAddressHome $RlcAddressHome"
echo "IexecHubAddressHome $IexecHubAddressHome" 
echo "RlcAddressForeign $RlcAddressForeign"
echo "IexecHubAddressForeign $IexecHubAddressForeign" 
echo "ADMIN_ADDRESS is : $ADMIN_ADDRESS" 
echo "ADMIN_PRIVATE_KEY is : $ADMIN_PRIVATE_KEY" 

echo "RlcAddressHome $RlcAddressHome" > memo
echo "IexecHubAddressHome $IexecHubAddressHome" >> memo
echo "RlcAddressForeign $RlcAddressForeign" >> memo
echo "IexecHubAddressForeign $IexecHubAddressForeign" >> memo
echo "ADMIN_ADDRESS is : $ADMIN_ADDRESS" >> memo
echo "ADMIN_PRIVATE_KEY is : $ADMIN_PRIVATE_KEY"  >> memo

