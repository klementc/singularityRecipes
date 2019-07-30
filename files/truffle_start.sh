#!/bin/bash 

function printHelp() {
    echo "--------------------------------------------"
    echo "Usage:"
    echo "truffle_start.sh <mode>"
    echo "<mode> clone deploy start test"
    echo "clone: fetches files needed for deployment"
    echo "deploy: create nodes directory"
    echo "start: start nodes (need to be deployed)"
    echo "test: make transaction between nodes (need to be started)"
    echo "--------------------------------------------"
}


function cloneFiles() {
    # clone repository
    echo " _____ _             
|     | |___ ___ ___ 
|   --| | . |   | -_|
|_____|_|___|_|_|___|
                     "
    cd
    if [ -d "contracts-experiment" ]; then
	echo "[Error] contracts-experiment directory already exists"
	exit 1
    fi

    git clone https://gitlab.com/clementcs/contracts-experiment.git
    cd  contracts-experiment/ethereum
    cd ethereum-contract
}

# start example
function init() {
    echo " ____          _         
|    \ ___ ___| |___ _ _ 
|  |  | -_| . | | . | | |
|____/|___|  _|_|___|_  |
          |_|       |___|"
    echo "[Info] Preparing and launching Geth"
    cd
    cd  contracts-experiment/ethereum/ethnet
    geth account list --datadir .
    geth --datadir . init ./genesis.json
    geth --port 4321 --networkid 15 --datadir=.  --rpc --rpcport 8543 --rpcaddr 127.0.0.1  --rpcapi "eth,net,web3,personal,miner" --allow-insecure-unlock &> geth.out &

    sleep 20

    echo "[Info] Unlock account"
    geth --exec "web3.personal.unlockAccount('0x94c31EA438E8B167EEd7f20EcCAC69961c5D70CB', 'aaaa', 1500000)" attach http://127.0.0.1:8543
    geth --exec "web3.personal.unlockAccount('0xaF1d2Af07bcac7fc6CCdE93CfA03C270ccB9FDb2', 'aaaa', 1500000)" attach http://127.0.0.1:8543
    geth --exec "web3.personal.unlockAccount('0xb595a97bc6039095fc3b6aa165e75a4ee79959e4', 'aaaa', 1500000)" attach http://127.0.0.1:8543

    echo "[Info] Balance:"
    geth  --exec "web3.fromWei(eth.getBalance('b595a97bc6039095fc3b6aa165e75a4ee79959e4'),'ether')" attach http://127.0.0.1:8543
    
    echo "[Info] Start mining"
    geth --exec "miner.start()" attach http://127.0.0.1:8543
}

function migrate(){
    cd
    cd  contracts-experiment/ethereum/
    cd ethereum-contract
    echo "[Info] Compile contract"
    
    
    echo "[Info] Migrate"
    truffle migrate # --reset
    
}

function testNodesCall() {
    #sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost 'flow start ExampleFlow$Initiator iouValue: 50, otherParty: "O=PartyB,L=New York,C=US"'
    echo " _____         _   _         
|_   _|___ ___| |_|_|___ ___ 
  | | | -_|_ -|  _| |   | . |
  |_| |___|___|_| |_|_|_|_  |
                        |___|"
    cd
    cd  contracts-experiment/ethereum
    cd ethereum-contract
    truffle exec /check.js

}


# main

DIR_BASE=$PWD

MODE=$1

if [ "$MODE" == "clone" ]; then
    cloneFiles
elif [ "$MODE" == "init" ]; then
    init
elif [ "$MODE" == "migrate" ]; then
    migrate
elif [ "$MODE" == "test" ]; then
    testNodesCall
elif [ "$MODE" == "stop" ]; then
    pkill geth
    echo "files not deleted, see $HOME/contact-experiments and $HOME/{.ethash,.ethereum} to remove"
else
    printHelp
fi

cd $DIR_BASE
