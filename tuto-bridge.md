#Prerequiste deploy 2 PoA chains in local vm

install Vagrant 2.2.4 : https://www.vagrantup.com/downloads.html
install vagrant virtual box provider https://www.vagrantup.com/docs/virtualbox/
install docker and docker compose on your host

vagrant up

Must end with :

You can connect and see containers in vm :

vagrant ssh

#1 ) ON your HOST (not the vm) deploy bridge smart contract 

somewhere :
rm -rf poa-bridge-contracts
git clone -b 2.2.0 https://github.com/poanetwork/poa-bridge-contracts.git
cd poa-bridge-contracts/deploy

curl https://raw.githubusercontent.com/branciard/blockchain-dev-env/master/poa-bridge-contracts-dev.env -o .env

Edit : __ADMIN_WALLET_PRIVATEKEY__

Edit : __ADMIN_WALLET__

Edit : __ERC20_TOKEN_ADDRESS__ (foreign token address)

cd poa-bridge-contracts/
Launch :
./deploy.sh  

or do 
docker-compose run bridge-contracts deploy.sh 

copy json content in a bridgeDeploymentResults.json file

#2 ) ON your HOST (not the vm) connect bridges agents to smart contracts 

somewhere :
git clone -b 1.1.0 https://github.com/poanetwork/token-bridge.git
cd token-bridge

curl https://raw.githubusercontent.com/branciard/blockchain-dev-env/master/token-bridge-dev.env -o .env


Edit : __ADMIN_WALLET_PRIVATEKEY__

Edit : __ADMIN_WALLET__

Edit : __ERC20_TOKEN_ADDRESS__ (foreign token address)

Edit : __HOME_BRIDGE_ADDRESS__ (see bridgeDeploymentResults.json) 
Edit : __FOREIGN_BRIDGE_ADDRESS__ (see bridgeDeploymentResults.json) 


docker-compose up -d rabbit  
docker-compose up -d redis
# wait 30 sec  rabbit connection to be ready ...
docker-compose up -d --build

check with 
docker-compose logs  -f

#3 ) ON your HOST (not the vm) start a bridge UI

git clone -b develop-iexec https://github.com/iExecBlockchainComputing/bridge-ui.git
cd bridge-ui
git submodule update --init --recursive --remote
npm install

curl https://raw.githubusercontent.com/branciard/blockchain-dev-env/master/bridge-ui-dev.env -o .env

Edit : __HOME_BRIDGE_ADDRESS__ (see bridgeDeploymentResults.json) 
Edit : __FOREIGN_BRIDGE_ADDRESS__ (see bridgeDeploymentResults.json) 

npm rebuild node-sass
npm run start