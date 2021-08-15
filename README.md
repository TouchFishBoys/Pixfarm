# Pixfarmon

1.创建钱包

2.从polygon test faucet（https://faucet.matic.network/）上获取货币

3.在钱包中添加自定义RPC（https://docs.matic.network/docs/develop/network-details/network/）

    chainId:80001 

    RPC:https://matic-testnet-archive-rpc.bwarelabs.com
    
4.Truffle-cofig.js配置文件

    const HDWalletProvider = require("@truffle/hdwallet-provider");
    const polygon = "https://rpc-mumbai.maticvigil.com";

    module.exports = {
 
      networks: {
        polygon: {
          provider: () => new HDWalletProvider(privateKey, polygon),
          gasPrice: 0,
          network_id: "*",
      skipDryRun: true,
      networkCheckTimeout: 600000
    },
    //  development: {
    //  host: "127.0.0.1",     // Localhost (default: none)
    //  port: 8545,            // Standard Ethereum port (default: none)
    //  network_id: "*",       // Any network (default: none)
    // }
    
      },
      mocha:{
       // timeout: 100000
      },

      compilers: {
        solc: {
         version: "^0.5.16",    // Fetch exact version from solc-bin (default: truffle's version)
        }
      },

    // plugins: ["truffle-contract-size"],
     // $ truffle migrate --reset --compile-all

     db: {
       enabled: false
      }
    };

5.2_deploy_contracts.js部署文件
    const bit = artifacts.require("Bitspawn");

    module.exports = function (deployer) {
  
      deployer.deploy(bit);

    };
    
6.终端命令
    
    Truffle migrate --reset --network polygon --compile-all
