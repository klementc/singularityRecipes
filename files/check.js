
var art = artifacts.require("MetaCoin");
const contract = require('truffle-contract')
const MyContract = contract(art);

module.exports = async function(callback) {

    MyContract.setProvider(web3.currentProvider);
    var accounts, instance;
    web3.eth.getAccounts().then(
	function(accs){
	    accounts = accs
	    console.log("[Info] Accounts addresses:"+accounts)
	    return MyContract.deployed()
		
	}).then(function(inst) {
	    instance = inst
	    
	    instance.getBalance(accounts[0]).then(function(b){
		console.log("[Info] Funds account Alice: "+b.toNumber())
	    });

	    instance.getBalance(accounts[1]).then(function(b1){
		console.log("[Info] Funds account Bob: "+b1.toNumber())
	    });

	    instance.getBalance(accounts[2]).then(function(b2){
		console.log("[Info] Funds account Charlie: "+b2.toNumber())
	    });
	    return instance.sendCoin(accounts[1], 1, {from: accounts[0]})
	}).then(async function(val){
	    //console.log(val.toNumber())
	    for (let step = 0; step < 300; step++) {
		console.log("step: "+step)
		// send one token from alice to bob
		instance.sendCoin(accounts[1], 1, {from: accounts[0]})
		// send one token from bob to charlie
		instance.sendCoin(accounts[2], 1, {from: accounts[1]})
		// send one token from charlie to alice
		instance.sendCoin(accounts[0], 1, {from: accounts[2]})

	    }
	});
    

    //checkAllBalances();
}
