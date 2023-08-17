// import { HardhatRuntimeEnvironment } from "hardhat/types";
import * as hre from 'hardhat';
import * as ehters from 'ethers';
import { Wallet, utils } from "zksync-web3";
import { Deployer } from '@matterlabs/hardhat-zksync-deploy';
import * as ye from "@matterlabs/hardhat-zksync-upgradable"; // important to keep, without this `.zkUpgrades` property would not be visible, for some reason.

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();
async function main() {
    // Initialize the wallet.1
    const zkWallet = Wallet.fromMnemonic(mnemonic);
    zkWallet
    const deployer = new Deployer(hre, zkWallet);

    const tokenContract = await deployer.loadArtifact("ZKHToken");
    const dev2Address = "0x6d2b9b23a5daca4128f04443ef0fccdd71bf9f47"; // Replace with the desired address
    const feeAddress = "0x6d2b9b23a5daca4128f04443ef0fccdd71bf9f47"; // Replace with the desired address
    const initialMint = "9000000000000000000000000000"; 
    const args = [dev2Address, feeAddress, initialMint];

    const verificationId = await hre.run("verify:verify", {
      address: "0x3F296fEDFbeB5B1101C58F04C7E46E978BfD996A",
      contract: "contracts/ZKHToken.sol:ZKHToken",
      constructorArguments: []
    });
    console.log('contract verified : ', verificationId);

    // const verificationId = await hre.run("verify:verify", {
    //     address: "0x8cc3Bb7fc3Ae5fC67cb4cA091610C8309CAF0b24",
    //     contract: "contracts/ZKHToken.sol:ZKHToken",
    //     constructorArguments: args
    // });
    // console.log('contract verified : ', verificationId);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
