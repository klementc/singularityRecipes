#!/bin/bash 

set -x

DIR_BASE=$PWD

# clone repository
git clone https://github.com/corda/samples
cd samples/cordapp-example

# start example

./gradlew deployNodes
cd workflows-java/build/nodes/
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

# start nodes
cd Notary
java -jar corda.jar --no-local-shell &
procN=$!
cd ..

cd PartyA
java -jar corda.jar --no-local-shell &
procA=$!
cd ..

cd PartyB
java -jar corda.jar --no-local-shell &
procB=$!
cd ..

cd PartyC
java -jar corda.jar --no-local-shell &
procC=$!
cd $DIR_BASE


sleep 120
sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost 'flow start ExampleFlow$Initiator iouValue: 50, otherParty: "O=PartyB,L=New York,C=US"'

sshpass -p "test" ssh  -p 2222 -o StrictHostKeyChecking=no user1@localhost 'run vaultQuery contractStateType: com.example.state.IOUState'
sleep 10

rm -rf samples
