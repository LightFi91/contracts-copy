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
    const deployer = new Deployer(hre, zkWallet);

    const tokenContract = await deployer.loadArtifact("ZKHarvestFactory");
    const feeAddress = "0x6d2b9b23a5daca4128f04443ef0fccdd71bf9f47"; // Replace with the desired address
    const args = [zkWallet.address, feeAddress];

    const beacon = await hre.zkUpgrades.deployBeacon(deployer.zkWallet, tokenContract);
    await beacon.deployed();
    console.log('ZKHarvestFactory Beacon deployed to: ', beacon.address);

    const zkhFactory = await hre.zkUpgrades.deployBeaconProxy(deployer.zkWallet, beacon, tokenContract, args);
    await zkhFactory.deployed();
    console.log('ZKHarvestFactory beacon proxy deployed to: ', zkhFactory.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
