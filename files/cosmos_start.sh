#!/bin/bash


BASE_DIR=$PWD
#export GOPATH="/tmp/go"
#export GOBIN=$GOPATH/bin
#export PATH=$PATH:$GOBIN
echo "gopath: $GOPATH"
echo "gobin: $GOBIN"
export NSDPATH=$PWD/.nsd
export NSCLIPATH=$PWD/.nscli
PASS="aaaaaaaa"

function clone() {
    echo " _____ _             
|     | |___ ___ ___ 
|   --| | . |   | -_|
|_____|_|___|_|_|___|
                     "
    mkdir -p $GOPATH
    mkdir -p $GOBIN

    if [ ! -d "contracts-experiment" ]; then
	git clone https://gitlab.com/clementcs/contracts-experiment.git
    fi

    mkdir -p $GOPATH/src/github.com/cosmos

    cp -R contracts-experiment/sdk-application-tutorial $GOPATH/src/github.com/cosmos
    cd $GOPATH/src/github.com/cosmos/sdk-application-tutorial
    make install
}


function init() {
    echo " _____ _           _   
|   __| |_ ___ ___| |_ 
|__   |  _| .'|  _|  _|
|_____|_| |__,|_| |_|  
                     "
    set -x
    rm -rf $NSDPATH
    
    # Initialize configuration files and genesis file
    # moniker is the name of your node
    nsd init coucou --chain-id namechain --home $NSDPATH


    # Copy the `Address` output here and save it for later use
    # [optional] add "--ledger" at the end to use a Ledger Nano S
    nscli keys add jack --home $NSCLIPATH <<EOF
$PASS
EOF
    # Copy the `Address` output here and save it for later use
    nscli keys add alice --home $NSCLIPATH <<EOF
$PASS
EOF

    # Add both accounts, with coins to the genesis file
    nsd add-genesis-account $(nscli keys show jack -a --home $NSCLIPATH) 1000nametoken,100000000stake --home $NSDPATH  --home-client $NSCLIPATH
    nsd add-genesis-account $(nscli keys show alice -a --home $NSCLIPATH) 1000nametoken,100000000stake --home $NSDPATH  --home-client $NSCLIPATH

    # Configure your CLI to eliminate need for chain-id flag
    nscli config chain-id namechain --home $NSCLIPATH
    nscli config output json --home $NSCLIPATH
    nscli config indent true --home $NSCLIPATH
    nscli config trust-node true --home $NSCLIPATH

    nsd gentx --home $NSDPATH --name jack --home-client $NSCLIPATH <<EOF
$PASS
EOF
    
    nsd collect-gentxs --home $NSDPATH
    nsd validate-genesis --home $NSDPATH 

    nsd start --home $NSDPATH --moniker coucou > cosmosd.log 2>&1&

    sleep 20

}

function gentransact() {
        echo " _____         _   _         
|_   _|___ ___| |_|_|___ ___ 
  | | | -_|_ -|  _| |   | . |
  |_| |___|___|_| |_|_|_|_  |
                        |___|"

    set -x
    nscli query account $(nscli keys show jack -a --home $NSCLIPATH) --home $NSCLIPATH
    nscli query account $(nscli keys show alice -a --home $NSCLIPATH) --home $NSCLIPATH

    echo "SENDING 20 tokens in 20 times from jack to alice"
    counter=1
    while [ $counter -le 20 ]
    do
	((counter++))	
	nscli tx bank send $(nscli keys show jack -a --home $NSCLIPATH) $(nscli keys show alice -a --home $NSCLIPATH) ${counter}nametoken --home $NSCLIPATH <<EOF
Y
$PASS
EOF
	sleep 5
    done
    
    nscli query account $(nscli keys show jack -a --home $NSCLIPATH) --home $NSCLIPATH
    nscli query account $(nscli keys show alice -a --home $NSCLIPATH) --home $NSCLIPATH
    echo "DONE"
}

MODE=$1

if [ "$MODE" == "clone" ]; then
    clone
elif [ "$MODE" == "init" ]; then
    init
elif [ "$MODE" == "test" ]; then
    gentransact
elif [ "$MODE" == "kill" ]; then
    pgrep -x nsd
    if [ $? -eq 0 ]; then
	pkill nsd
    fi
fi

cd $BASE_DIR
