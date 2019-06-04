Bootstrap: docker
From: hyperledger/fabric-ca

%help

%environment
      export FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server
      export FABRIC_CA_SERVER_CA_NAME=ca.example.com
      export FABRIC_CA_SERVER_CA_CERTFILE=/etc/hyperledger/fabric-ca-server-config/ca.org1.example.com-cert.pem
      export FABRIC_CA_SERVER_CA_KEYFILE=/etc/hyperledger/fabric-ca-server-config/4239aa0dcd76daeeb8ba0cda701851d14504d31aad1b2ddddbac6a57365e497c_sk

%post
	      mkdir -p fabric-ca.root

%runscript
	sh -c 'fabric-ca-server start -b admin:adminpw'
	
%files
	./crypto-config/peerOrganizations/org1.example.com/ca/ /etc/hyperledger/fabric-ca-server-config
%labels
	AUTHOR klement
