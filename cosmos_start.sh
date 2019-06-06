#!/bin/bash

set -x

BASE_DIR=$PWD
echo "export GO111MODULE=on"
echo "\033[36m"INFO"\033[0m Set env variables"
export GOPATH="/tmp/go"
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN

mkdir -p $GOPATH
mkdir -p $GOBIN


mkdir -p $GOPATH/src/github.com/ && cd $GOPATH/src/github.com/
mkdir -p cosmos && cd cosmos

git clone https://github.com/cosmos/sdk-application-tutorial.git
cd sdk-application-tutorial
echo $PATH $GOPATH $GOBIN
go get ./...
make install

export NSDPATH=$PWD/.nsd
# Now you should be able to run the following commands:
nsd help
nscli help


nsd start &
# Initialize configuration files and genesis file
  # moniker is the name of your node
nsd init coucou --chain-id namechain --home $NSDPATH


# Copy the `Address` output here and save it for later use
# [optional] add "--ledger" at the end to use a Ledger Nano S
nscli keys add jack --home $NSDPATH

# Copy the `Address` output here and save it for later use
nscli keys add alice --home $NSDPATH

# Add both accounts, with coins to the genesis file
nsd add-genesis-account $(nscli keys show jack -a) 1000nametoken,100000000stake --home $NSDPATH
nsd add-genesis-account $(nscli keys show alice -a) 1000nametoken,100000000stake --home $NSDPATH

# Configure your CLI to eliminate need for chain-id flag
nscli config chain-id namechain --home $NSDPATH
nscli config output json --home $NSDPATH
nscli config indent true --home $NSDPATH
nscli config trust-node true --home $NSDPATH

nsd gentx --name jack --home $NSDPATH

# First check the accounts to ensure they have funds
nscli query account $(nscli keys show jack -a) --home $NSDPATH
nscli query account $(nscli keys show alice -a) --home $NSDPATH

# Buy your first name using your coins from the genesis file
nscli tx nameservice buy-name jack.id 5nametoken --from jack --home $NSDPATH

# Set the value for the name you just bought
nscli tx nameservice set-name jack.id 8.8.8.8 --from jack --home $NSDPATH

# Try out a resolve query against the name you registered
nscli query nameservice resolve jack.id --home $NSDPATH
# > 8.8.8.8

# Try out a whois query against the name you just registered
nscli query nameservice whois jack.id --home $NSDPATH
# > {"value":"8.8.8.8","owner":"cosmos1l7k5tdt2qam0zecxrx78yuw447ga54dsmtpk2s","price":[{"denom":"nametoken","amount":"5"}]}

# Alice buys name from jack
nscli tx nameservice buy-name jack.id 10nametoken --from alice --home $NSDPATH
ls $GOBIN
cd $GOPATH
cd .. && rm -rf go

pkill nsd
