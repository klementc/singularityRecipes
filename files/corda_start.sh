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
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2223"
    ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2224"
    
    cd  contracts-experiment/corda-dapp/cordapp-token-ownable/
    cd build/nodes/
    for entity in "PartyA" "PartyB" "PartyC" "Notary"; do
	echo "[Info] starting $entity"
	if [ -d ${entity} ]; then
#	    set -x
	    cd $entity
	    java -jar corda.jar --no-local-shell &
	    cd ..
	    #set +x
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
    echo "Testing for ssh servers"
    #sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost env;s1=$?
    #sshpass -p "test" ssh  -p 2223 -o StrictHostKeyChecking=no user1@localhost env;s2=$?
    #sshpass -p "test" ssh  -p 2224 -o StrictHostKeyChecking=no user1@localhost env;s3=$?
    /passh/passh -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost "env";s1=$?
    /passh/passh -p "test" ssh  -p 2223 -o StrictHostKeyChecking=no user1@localhost "env";s2=$?
    /passh/passh -p "test" ssh  -p 2224 -o StrictHostKeyChecking=no user1@localhost "env";s3=$?
    
    while [  $s1 -gt 0 ] || [ $s2 -gt 0 ] || [ $s3 -gt 0 ];
    do
	echo "Cannot ssh now. Retrying in 20 sec"
	sleep 20
	#sshpass -p "test" ssh -vvv -p 2222 -o StrictHostKeyChecking=no user1@localhost env;s1=$?
	#sshpass -p "test" ssh -vvv -p 2223 -o StrictHostKeyChecking=no user1@localhost env;s2=$?
	#sshpass -p "test" ssh -vvv -p 2224 -o StrictHostKeyChecking=no user1@localhost env;s3=$?
	/passh/passh -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost "env";s1=$?
	/passh/passh -p "test" ssh  -p 2223 -o StrictHostKeyChecking=no user1@localhost "env";s2=$?
	/passh/passh -p "test" ssh  -p 2224 -o StrictHostKeyChecking=no user1@localhost "env";s3=$?
    
    done
    
	
    
    echo "Funding accounts with 100 tokens:"
    echo "- PartyA: 100 tokens"
    #sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost start com.template.IssueTokenFlow amount: 100
    /passh/passh -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost "start com.template.IssueTokenFlow amount: 100"
    echo "- PartyB: 100 tokens"
    #sshpass -p "test" ssh  -p 2223 -o StrictHostKeyChecking=no user1@localhost start com.template.IssueTokenFlow amount: 100
    /passh/passh -p "test" ssh  -p 2223 -o StrictHostKeyChecking=no user1@localhost "start com.template.IssueTokenFlow amount: 100"
    echo "- PartyB: 100 tokens"
    #sshpass -p "test" ssh  -p 2224 -o StrictHostKeyChecking=no user1@localhost start com.template.IssueTokenFlow amount: 100
    /passh/passh -p "test" ssh  -p 2224 -o StrictHostKeyChecking=no user1@localhost "start com.template.IssueTokenFlow amount: 100"
    echo "Accounts funded, trading tokens now"
    nbIter=300
    counter=1
    while [ $counter -le $nbIter ]
    do
	echo "step: $counter"
	((counter++))
	# PartyA -> PartyB
	#sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost "start com.template.TransferTokenFlow receiver: 'O=PartyB,L=New York,C=US', amountToTransfer: 1" 
	# PartyB -> PartyC
	#sshpass -p "test" ssh  -p 2223 -o StrictHostKeyChecking=no user1@localhost "start com.template.TransferTokenFlow receiver: 'O=PartyC,L=Paris,C=FR', amountToTransfer: 1" 
	# PartyC -> PartyA
	#sshpass -p "test" ssh  -p 2224 -o StrictHostKeyChecking=no user1@localhost "start com.template.TransferTokenFlow receiver: 'O=PartyA,L=London,C=GB', amountToTransfer: 1"

	/passh/passh -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost "start com.template.TransferTokenFlow receiver: 'O=PartyB,L=New York,C=US', amountToTransfer: 1" 
	# PartyB -> PartyC
	/passh/passh -p "test" ssh  -p 2223 -o StrictHostKeyChecking=no user1@localhost "start com.template.TransferTokenFlow receiver: 'O=PartyC,L=Paris,C=FR', amountToTransfer: 1" 
	# PartyC -> PartyA
	/passh/passh -p "test" ssh  -p 2224 -o StrictHostKeyChecking=no user1@localhost "start com.template.TransferTokenFlow receiver: 'O=PartyA,L=London,C=GB', amountToTransfer: 1"
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
