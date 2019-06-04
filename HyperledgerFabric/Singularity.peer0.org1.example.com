Bootstrap: docker
From: hyperledger/fabric-peer

%help

%environment
      export CORE_PEER_ID=peer0.org1.example.com
      export  FABRIC_LOGGING_SPEC=info
      export CORE_CHAINCODE_LOGGING_LEVEL=info
      export CORE_PEER_LOCALMSPID=Org1MSP
      export CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/peer/
      export CORE_PEER_ADDRESS=127.0.0.1:7051
      export CORE_OPERATIONS_LISTENADDRESS=127.0.0.1:10443
      export CORE_LEDGER_STATE_STATEDATABASE=CouchDB
      export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=127.0.0.1:5984
      # The CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME and CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD
      # provide the credentials for ledger to connect to CouchDB.  The username and password must
      # match the username and password set for the associated CouchDB.
      export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=
      export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=
#      export CORE_PEER_FILESYSTEMPATH=$TMP


%post
%runscript
      peer node start --peer-chaincodedev=true


%files
	./core.yaml /etc/hyperledger/fabric/core.yaml
        ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp /etc/hyperledger/msp/peer
        ./crypto-config/peerOrganizations/org1.example.com/users /etc/hyperledger/msp/users
        ./config /etc/hyperledger/configtx

%labels
	AUTHOR klement
