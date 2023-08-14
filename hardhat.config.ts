import { HardhatUserConfig } from "hardhat/config";

import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-verify";
import "@matterlabs/hardhat-zksync-upgradable";

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();
const alchemyAPIKey = "WOCmHzWzM75YJVRYkIKNkpq2KNYRyQnX";

const config: HardhatUserConfig = {
  solidity: { 
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    }
  },
  zksolc: {
    version: "latest",
    settings: { }
  },
  defaultNetwork: "zkSyncTestnet",
  networks: {
    hardhat: { zksync: false},
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${alchemyAPIKey}`, // The Ethereum Web3 RPC URL (optional).
      zksync: false, // disables zksolc compiler
    },
    zkSyncTestnet: {
      url: "https://testnet.era.zksync.dev", // The testnet RPC URL of zkSync Era network.
      ethNetwork: "goerli", // The Ethereum Web3 RPC URL, or the identifier of the network (e.g. `mainnet` or `goerli`)
      zksync: true, // enables zksolc compiler
    }
  }
};

export default config;
