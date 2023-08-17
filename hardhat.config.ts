// import { HardhatUserConfig } from "hardhat/config";

// import '@typechain/hardhat'
// import '@nomiclabs/hardhat-ethers'
// import '@nomicfoundation/hardhat-chai-matchers'
import "@matterlabs/hardhat-zksync-toolbox";
import "@matterlabs/hardhat-zksync-deploy";
import "@matterlabs/hardhat-zksync-solc";
import "@matterlabs/hardhat-zksync-verify";
import "@matterlabs/hardhat-zksync-upgradable";
import "@nomicfoundation/hardhat-ethers";
import '@typechain/hardhat'
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();
const alchemyAPIKey = "WOCmHzWzM75YJVRYkIKNkpq2KNYRyQnX";
import { HardhatUserConfig } from "hardhat/config";


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
    settings: { 
      optimizer: {
        enabled: true,
        mode: '3'
      }
    }
  },
  defaultNetwork: "zkSyncTestnet",
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${alchemyAPIKey}`, // The Ethereum Web3 RPC URL (optional).
      zksync: false, // disables zksolc compiler
    },
    zkSyncTestnet: {
      url: "https://testnet.era.zksync.dev", // The testnet RPC URL of zkSync Era network.
      ethNetwork: "goerli", // The Ethereum Web3 RPC URL, or the identifier of the network (e.g. `mainnet` or `goerli`)
      zksync: true, // enables zksolc compiler
      verifyURL: 'https://zksync2-testnet-explorer.zksync.dev/contract_verification', // Verification endpoint for georli
      gas: 2100000,
      gasPrice: 8000000000,
      // Mainnet: https://zksync2-mainnet-explorer.zksync.io/contract_verification
    }
  },
  etherscan: {
    apiKey: "45EJJJRDBZMIKBXVKH4B4PBU716E5F3J5S",
  }
};

export default config;
