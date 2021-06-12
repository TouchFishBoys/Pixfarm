const HDWalletProvider = require("truffle-hdwallet-provider");

// const privateKey = process.env.PRIVATE_KEY;
const privateKey =
  "3e72023b6eb2a8994edd33119e9f2c523850b63834e194cd4481567ab1ce52c5";
const skale = "https://dev-testnet-v1-1.skalelabs.com";

module.exports = {
  networks: {
    skale: {
      provider: () => new HDWalletProvider(privateKey, skale),
      gasPrice: 0,
      network_id: "*",
      skipDryRun: true
    },
    development: {
      host: "54.144.133.190",
      port: 8545,
      network_id: "*"
    }
  },
  mocha: {},
  compilers: {
    solc: {
      version: "^0.8.0",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  },

  plugins: ["truffle-contract-size"]
};
