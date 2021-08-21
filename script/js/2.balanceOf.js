var Web3 = require("web3");
var Tx = require('ethereumjs-tx');

const fs = require('fs');
// const infuraKey = fs.readFileSync("./test/bob.infuraKey").toString().trim();
var web3 = new Web3(new Web3.providers.HttpProvider(`https://rpc-mumbai.maticvigil.com`));

//读取num属性
async function getBalance(contractObj,fromAddr) {
    let myValue = await contractObj.methods.balanceOf(fromAddr).call({from:fromAddr});
    console.log("balanceOf: ",myValue);
}

function getPriKey(prikeyPath) {
    const privKeyFile = fs.readFileSync(prikeyPath).toString().trim();
    const privKey = new Buffer.from(privKeyFile, 'hex');    
    return privKey
}


function sendSigned(txData, cb) {
    const privateKey = new Buffer.from(privKey, 'hex')
    const transaction = new Tx(txData)
    transaction.sign(privateKey)
    const serializedTx = transaction.serialize().toString('hex')
    web3.eth.sendSignedTransaction('0x' + serializedTx, cb)
}

function getEthRawTx(fromAddress,toAddress,contractObj,nonceNum,privKey) {
    //raw Tx
    var rawTransaction = {
        "from": fromAddress,
        "nonce": web3.utils.toHex(nonceNum),
        "gasLimit": web3.utils.toHex(6000000),
        "gasPrice": web3.utils.toHex(10e9),
        "to": toAddress,
        "value": web3.utils.toHex(0),
        "data": contractObj.methods.balanceOf(fromAddress).encodeABI(),  //设置num属性
        "chainId": 80001 //4:Rinkeby, 3:Ropsten, 1:mainnet, 80001:polygon testnet
    };

    var tx = new Tx(rawTransaction);
    tx.sign(privKey);
    var serializedTx = tx.serialize();
    return serializedTx;
}

async function signTransaction(fromAddress,toAddress,contractObj,nonceNum, privKey) {
    var serializedTx = getEthRawTx(fromAddress,toAddress,contractObj,nonceNum, privKey)

    // Comment out these three lines if you don't really want to send the TX right now
    console.log(`Attempting to send signed tx:  ${serializedTx.toString('hex')}`);
    var receipt = await web3.eth.sendSignedTransaction('0x' + serializedTx.toString('hex'));
    console.log(`Receipt info:  ${JSON.stringify(receipt, null, '\t')}`);
}

function sleep(delay) {
    return new Promise(reslove => {
      setTimeout(reslove, delay)
    })
}

const mintToken = async (_address) => {
    //rinkeby主账户地址
    var fromAddress = "0x8AF41Cacb5FE289587292BA3c7eaa4a65b383c80";
    
    //bob合约的abi
    var bobAbi = fs.readFileSync("../abi/DSTokenBase.json","utf-8");

    // bob合约地址
    var bobAddress = "0x4d1AaAC5fb738e299646346e4A4aAad54fD7A6A6";
    
    // get the nonce
    var nonceCnt = await web3.eth.getTransactionCount(fromAddress);
    console.log(`num transactions so far: ${nonceCnt}`);

    //通过ABI和地址获取已部署的合约对象
    var contract = new web3.eth.Contract(JSON.parse(bobAbi), bobAddress,{from:_address});

    //await getBalance(contract,fromAddress);

    const privkey = getPriKey("../keys/edgekey")
    await signTransaction(_address,bobAddress,contract,nonceCnt, privkey)

    sleep(100) //100ms

    console.log("after mint");
    await getBalance(contract,_address);
    
}

// mintToken(70).then = function(){
//     console.log('> > > > > > called .then on %o with arguments: %o', this, arguments);
//     return originalThen.apply(this, arguments);
// };

// Promise.prototype.catch = function(){
//     console.error('> > > > > > called .catch on %o with arguments: %o', this, arguments);
//     return originalCatch.apply(this, arguments);
// };

mintToken("0x8AF41Cacb5FE289587292BA3c7eaa4a65b383c80")
  .then((value) => {
    console.log(value);
    // expected output: "Success!"
  })
  .catch((error) => {
    console.log(error);
    // expected output: "Success!"
  });