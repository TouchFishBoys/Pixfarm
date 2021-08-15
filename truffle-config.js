const HDWalletProvider = require("truffle-hdwallet-provider");

// const privateKey = process.env.PRIVATE_KEY;
const privateKey =
  "91218c9ef59fe4ae8fda0cb0c8086756191f311850e673721822dcabce1c99c9";
const skale = "https://dev-testnet-v1-1.skalelabs.com";

module.exports = {
  networks: {
    skale: {
      provider: () => new HDWalletProvider(privateKey, skale),
      gasPrice: 0,
      network_id: "*",
      skipDryRun: true
    },
    polygon: {
      provider: () => new HDWalletProvider(privateKey, polygon),
      gasPrice: 0,
      network_id: "*",
      skipDryRun: true,
      networkCheckTimeout: 600000
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
