module.exports = {
  networks: {
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
