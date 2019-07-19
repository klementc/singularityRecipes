module.exports = function(callback) {
    let Web3 = require('web3');
  const truffleContract = require('truffle-contract')
  let contract = truffleContract(require('../build/contracts/MetaCoin.json'));
  var provider = new Web3.providers.HttpProvider("http://localhost:8545");
  var web3 = new Web3(provider);
  contract.setProvider(web3.currentProvider);

  //workaround: https://github.com/trufflesuite/truffle-contract/issues/57
  if (typeof contract.currentProvider.sendAsync !== "function") {
    contract.currentProvider.sendAsync = function() {
      return contract.currentProvider.send.apply(
        contract.currentProvider, arguments
      );
    };
  }

  contract.deployed().then(function(instance){
    return instance.yourFunction();
  }).then(response => {
    console.log(response);
  });
}
