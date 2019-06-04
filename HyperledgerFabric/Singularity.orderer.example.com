Bootstrap: docker
From: hyperledger/fabric-orderer

%help

%environment
      export FABRIC_LOGGING_SPEC=info
      export ORDERER_GENERAL_LISTENADDRESS=127.0.0.1
      export ORDERER_GENERAL_GENESISMETHOD=file
      export ORDERER_GENERAL_GENESISFILE=/etc/hyperledger/configtx/genesis.block
      export ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      export ORDERER_GENERAL_LOCALMSPDIR=/etc/hyperledger/msp/orderer/msp
      export ORDERER_FILELEDGER_LOCATION=/var


%post
	      mkdir -p orderer.root
	      mkdir -p /var/hyperledger/production/orderer/index
	      mkdir -p /var/index/
%runscript
      orderer
	
%files
	./orderer.yaml /etc/hyperledger/fabric/orderer.yaml
        ./config/ /etc/hyperledger/configtx
        ./crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/ /etc/hyperledger/msp/orderer
        ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/ /etc/hyperledger/msp/peerOrg1

%labels
	AUTHOR klement
k
