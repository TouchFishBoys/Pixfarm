var Web3 = require("web3");
//连接到Ganache
var web3 = new Web3(new Web3.providers.HttpProvider('https://rpc-mumbai.maticvigil.com'));

var fs = require("fs");
var data = fs.readFileSync("../build/contracts/DSTokenBase.json", "utf-8");

//创建合约对象
var contract = new web3.eth.Contract(JSON.parse(data),'0x4d1AaAC5fb738e299646346e4A4aAad54fD7A6A6');

var personAddress="0x8AF41Cacb5FE289587292BA3c7eaa4a65b383c80";

//调用合约的方法
//我们可以在Remix中设置，在这里读取，或者反过来。交叉验证更加直观。
 contract.methods.balanceOf(personAddress).call().then(console.log);
 //contract.methods.mint(200).send({from:'0x8AF41Cacb5FE289587292BA3c7eaa4a65b383c80'}).then(console.log);
