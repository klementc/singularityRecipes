#!/bin/bash 

function printHelp() {
    echo "--------------------------------------------"
    echo "Usage:"
    echo "corda_start.sh <mode>"
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
    if [ -d "contracts-experiment" ]; then
	echo "[Error] contracts-experiment directory already exists"
	exit 1
    fi

    git clone https://gitlab.com/clementcs/contracts-experiment.git
    cd  contracts-experiment/corda-dapp/cordapp-token-ownable/
}

# start example
function deployWithSSH() {
    echo " ____          _         
|    \ ___ ___| |___ _ _ 
|  |  | -_| . | | . | | |
|____/|___|  _|_|___|_  |
          |_|       |___|"
    #set -x
    cd  contracts-experiment/corda-dapp/cordapp-token-ownable/
    if [ ! -f "gradlew" ]; then
	echo "[Error] gradlew doesn't exist, launch this script from the project directory"
	exit 1
    fi
    ./gradlew deployNodes
    cd build/nodes/
    set +x
    
    # ADD SSH ACCESS TO PARTY NODES

    # Connect to partyA with: 
    # $ sshpass -p "test" ssh user1@localhost -p 2222 -o StrictHostKeyChecking=no
    echo "sshd {port = 2222}" >> PartyA/node.conf

    # Connect to partyB with: 
    # $ sshpass -p "test" ssh user1@localhost -p 2223 -o StrictHostKeyChecking=no
    echo "sshd {port = 2223}" >> PartyB/node.conf

    # Connect to partyA with: 
    # $ sshpass -p "test" ssh user1@localhost -p 2224 -o StrictHostKeyChecking=no
    echo "sshd {port = 2224}" >> PartyC/node.conf
}

function startAllNodes() {
    # start nodes
    echo " _____ _           _   
|   __| |_ ___ ___| |_ 
|__   |  _| .'|  _|  _|
|_____|_| |__,|_| |_|  
                     "
    cd  contracts-experiment/corda-dapp/cordapp-token-ownable/
    cd build/nodes/
    for entity in "PartyA" "PartyB" "PartyC" "Notary"; do
	echo "[Info] starting $entity"
	if [ -d ${entity} ]; then
#	    set -x
	    cd $entity
	    java -jar corda.jar --no-local-shell &
	    cd ..
#	    set +x
	else
	    echo "[ERROR] NODES NEED TO BE DEPLOYED BEFORE STARTED. If already done, verify you launched the script from the root of the project."
	    exit 1
	fi
	
    done
}

function testNodesCall() {
    #sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost 'flow start ExampleFlow$Initiator iouValue: 50, otherParty: "O=PartyB,L=New York,C=US"'
    echo " _____         _   _         
|_   _|___ ___| |_|_|___ ___ 
  | | | -_|_ -|  _| |   | . |
  |_| |___|___|_| |_|_|_|_  |
                        |___|"
    cd  contracts-experiment/corda-dapp/cordapp-token-ownable/
    #set -x
    echo "Adding money to accounts:"
    echo "- PartyA: 1337 tokens"
    sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost start com.template.IssueTokenFlow amount: 1337
    echo "- PartyB: 420 tokens"
    sshpass -p "test" ssh  -p 2223 -o StrictHostKeyChecking=no user1@localhost start com.template.IssueTokenFlow amount: 420
    echo "- PartyB: 2019 tokens"
    sshpass -p "test" ssh  -p 2224 -o StrictHostKeyChecking=no user1@localhost start com.template.IssueTokenFlow amount: 2019

    echo "Accounts funded, trading tokens now"
    counter=1
    while [ $counter -le 20 ]
    do
	((counter++))	
	sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost "start com.template.TransferTokenFlow receiver: 'O=PartyC,L=Paris,C=FR', amountToTransfer: 3.141592653589"
    done
#    set +x
    echo "done"
}

# main

DIR_BASE=$PWD

MODE=$1

if [ "$MODE" == "clone" ]; then
    cloneFiles
elif [ "$MODE" == "deploy" ]; then
    deployWithSSH
elif [ "$MODE" == "start" ]; then
    startAllNodes
elif [ "$MODE" == "test" ]; then
    testNodesCall
else
    printHelp
fi

cd $DIR_BASE
