#!/bin/bash


BASE_DIR=$PWD

echo "gopath: $GOPATH"
echo "gobin: $GOBIN"
export NSDPATH=$PWD/.nsd
export NSCLIPATH=$PWD/.nscli

# password for accounts
export PASS="aaaaaaaa"

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
    nsd init mon --chain-id namechain --home $NSDPATH


    # Create accounts
    # One account for Alice, one for Bob, one for Charlie
    nscli keys add alice --home $NSCLIPATH <<EOF
$PASS
EOF
    nscli keys add bob --home $NSCLIPATH <<EOF
$PASS
EOF
    nscli keys add charlie --home $NSCLIPATH <<EOF
$PASS
EOF

    # Add the 3 accounts, with coins to the genesis file
    nsd add-genesis-account $(nscli keys show alice -a --home $NSCLIPATH) 100token,100000000stake --home $NSDPATH  --home-client $NSCLIPATH
    nsd add-genesis-account $(nscli keys show bob -a --home $NSCLIPATH) 100token,100000000stake --home $NSDPATH  --home-client $NSCLIPATH
    nsd add-genesis-account $(nscli keys show charlie -a --home $NSCLIPATH) 100token,100000000stake --home $NSDPATH  --home-client $NSCLIPATH

    # Configure your CLI to eliminate need for chain-id flag
    nscli config chain-id namechain --home $NSCLIPATH
    nscli config output json --home $NSCLIPATH
    nscli config indent true --home $NSCLIPATH
    nscli config trust-node true --home $NSCLIPATH

    # genesis transaction
    nsd gentx --home $NSDPATH --name alice --home-client $NSCLIPATH <<EOF
$PASS
EOF

    # fetch the genesis transation
    nsd collect-gentxs --home $NSDPATH
    # validate the genesis transaction
    nsd validate-genesis --home $NSDPATH 

    # everything ready, start the daemon
    nsd start --home $NSDPATH --moniker mon > cosmosd.log 2>&1&
}

function gentransact() {
        echo " _____         _   _         
|_   _|___ ___| |_|_|___ ___ 
  | | | -_|_ -|  _| |   | . |
  |_| |___|___|_| |_|_|_|_  |
                        |___|"

    set +x
    nscli query account $(nscli keys show alice -a --home $NSCLIPATH) --home $NSCLIPATH
    nscli query account $(nscli keys show bob -a --home $NSCLIPATH) --home $NSCLIPATH
    nscli query account $(nscli keys show charlie -a --home $NSCLIPATH) --home $NSCLIPATH
    echo "SENDING 20 tokens in 20 times from jack to alice"
    counter=1
    nbIter=100
    
    while [ $counter -le $nbIter ]
    do
	
	if [ $counter -gt 1 ]; then
	    nscli query tx $a --trust-node > /dev/null 2>&1
	    at=$?
	    while [ $at -eq 1 ]
	    do
		nscli query tx $a --trust-node > /dev/null 2>&1
		at=$?
	    done
	fi
	
	a=$(nscli tx --trace bank send $(nscli keys show alice -a --home $NSCLIPATH) $(nscli keys show bob -a --home $NSCLIPATH) 1token --home $NSCLIPATH <<EOF
Y
$PASS
EOF
	    )

	a=$(echo $a | jq -r ".txhash")
	
	if [ $counter -gt 1 ]; then
	    nscli query tx $b --trust-node > /dev/null 2>&1
	    bt=$?
	    while [ $bt -eq 1 ]
	    do
		nscli query tx $b --trust-node > /dev/null 2>&1
		bt=$?
	    done
	fi
	b=$(nscli tx --trace bank send $(nscli keys show bob -a --home $NSCLIPATH) $(nscli keys show charlie -a --home $NSCLIPATH) 1token --home $NSCLIPATH <<EOF
Y
$PASS
EOF
	 )
	b=$(echo $b | jq -r ".txhash")
	
	
	if [ $counter -gt 1 ]; then
	    nscli query tx $c --trust-node > /dev/null 2>&1
	    ct=$?
	    while [ $ct -eq 1 ]
	    do
		nscli query tx $c --trust-node > /dev/null 2>&1
		ct=$?
	    done
	fi
	c=$(nscli tx --trace bank send $(nscli keys show charlie -a --home $NSCLIPATH) $(nscli keys show alice -a --home $NSCLIPATH) 1token --home $NSCLIPATH <<EOF
Y
$PASS
EOF
	 )
	c=$(echo $c | jq -r ".txhash")
	
	
	    
	set +x

	((counter++))	

#		sleep 5
    done
    
    nscli query account $(nscli keys show alice -a --home $NSCLIPATH) --home $NSCLIPATH
    nscli query account $(nscli keys show bob -a --home $NSCLIPATH) --home $NSCLIPATH
    nscli query account $(nscli keys show charlie -a --home $NSCLIPATH) --home $NSCLIPATH
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

