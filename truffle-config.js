const HDWalletProvider = require("truffle-hdwallet-provider");
const fs = require("fs");

module.exports = {
    // See <http://truffleframework.com/docs/advanced/configuration>
    // to customize your Truffle configuration!
    networks: {
        development: {
            host: "127.0.0.1", // Localhost (default: none)
            port: 7545, // Standard Ethereum port (default: none)
            network_id: "5777", // Any network (default: none)
            from: "0xfB352202e1AaD6d0f0B7d0E50abd4AD2bAe4d81B" 
        }
    },
    compilers: {
        solc: {
            version: "0.8.6"
        }
    }
};
