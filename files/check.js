
var art = artifacts.require("MetaCoin");
const contract = require('truffle-contract')
const MyContract = contract(art);

module.exports = async function(callback) {

    MyContract.setProvider(web3.currentProvider);
    var accounts, instance;
    web3.eth.getAccounts().then(
	function(accs){
	    accounts = accs
	    console.log("accounts:"+accounts)
	    return MyContract.deployed()
		
	}).then(function(inst) {
	    instance = inst

	    return instance.getBalance(accounts[0])
	}).then(function(val){
	    console.log(val.toNumber())
	    return instance.sendCoin(accounts[1], 1, {from: accounts[0]})
	}).then(function(t){
	    console.log(t)
	    return instance.getBalance(accounts[0])
	}).then(async function(val){
	    console.log(val.toNumber())
	    for (let step = 0; step < 100; step++) {
		// Runs 5 times, with values of step 0 through 4.
		/*let t = await*/ instance.sendCoin(accounts[2], 1, {from: accounts[0]})
		let b = await instance.getBalance(accounts[0])
		console.log(b.toNumber())
		/*.then(
		   
		   function(t){
			instance.getBalance(accounts[0]).then(function(val){console.log(val.toNumber())})
		    })*/
	    }
	});
    

    //checkAllBalances();
}
