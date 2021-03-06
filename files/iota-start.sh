#!/bin/sh

function printHelp() {
    echo "--------------------------------------------"
    echo "Usage:"
    echo "iota.sh <mode>"
    echo "<mode> install startIri checkInfo makeSnapshot milestone"
    echo "--------------------------------------------"
}

function install() {
    # WARNING DON'T USE IRI > 1.5.4
    
    set +x
    if [ ! -d ./node ]; then
	echo "[Info] Node directory not found, creating it"
	mkdir ./node
    fi

    echo "[Info] moving jar to node"
    set -x
    cd node
    wget https://github.com/iotaledger/iri/releases/download/v1.5.4/iri-1.5.4.jar
    cd ..
    set +x
    
    echo "[Info] Installing iota private network"
    if [ ! -d private-iota-testnet ]; then
	echo "[Info] private-iota-testnet not found, downloading it"
	git clone https://github.com/schierlm/private-iota-testnet.git
    fi
    cd private-iota-testnet/
    mvn package
    
}

function startIri() {
    cd node
    echo "[Info] Starting IRI"
    set -x
    java -jar iri-1.5.4.jar --testnet --testnet-no-coo-validation --snapshot=Snapshot.txt -p 14700
    set +x
    cd ..
}

function checkInfo() {
    set -x
    curl -H "X-IOTA-API-Version: 1.5.4" -X POST -d '{"command":"getNodeInfo"}' http://localhost:14700
    set +x
}

function makeSnapshot() {
    echo "[Info] creating snapshot"
    if [ ! -f private-iota-testnet/target/iota-testnet-tools-0.1-SNAPSHOT-jar-with-dependencies.jar ]; then
	echo "[Error] install private testnet first (iota-testnet-tools-0.1-SNAPSHOT-jar-with-dependencies.jar required)"
	exit 1
    fi
    set -x
    java -jar private-iota-testnet/target/iota-testnet-tools-0.1-SNAPSHOT-jar-with-dependencies.jar SnapshotBuilder
    set +x
    echo "[Info] Moving Snapshot.{log,txt} to node directory."
    cp Snapshot.{log,txt} node/
}

function buildMilestone() {
    echo "[Info] creating milestone"
    if [ ! -f private-iota-testnet/target/iota-testnet-tools-0.1-SNAPSHOT-jar-with-dependencies.jar ]; then
	echo "[Error] install private testnet first (iota-testnet-tools-0.1-SNAPSHOT-jar-with-dependencies.jar required)"
	exit 1
    fi
    set -x
    java -jar private-iota-testnet/target/iota-testnet-tools-0.1-SNAPSHOT-jar-with-dependencies.jar Coordinator localhost 14700
    set +x
}

function iota() {
    #OLDIFS=$IFS
    #IFS=$'\n'
    a=($(cat Snapshot.log | grep Seed | awk '{ printf "%s\n",$2 }'))
    echo "[Info] Accounts seeds found:"
    echo "${a[@]}"
    echo "[Info] end of seeds"
    echo "${a[1]}"

    #IFS=$OLDIFS

}


MODE=$1

if [ "$MODE" == "install" ]; then
    install
elif [ "$MODE" == "startIri" ]; then
    startIri
elif [ "$MODE" == "checkInfo" ]; then
    checkInfo
elif [ "$MODE" == "test" ]; then
    testNodesCall
elif [ "$MODE" == "makeSnapshot" ]; then
    makeSnapshot
elif [ "$MODE" == "milestone" ]; then
    buildMilestone
elif [ "$MODE" == "iota-cli" ]; then
    iota
else
    printHelp
fi
