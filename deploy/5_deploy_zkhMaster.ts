// import { HardhatRuntimeEnvironment } from "hardhat/types";
import * as hre from 'hardhat';
import * as ethers from 'ethers';
import { Wallet, Contract } from "zksync-web3";
import { Deployer } from '@matterlabs/hardhat-zksync-deploy';
import * as ye from "@matterlabs/hardhat-zksync-upgradable"; // important to keep, without this `.zkUpgrades` property would not be visible, for some reason.
import * as treasurerArtifact from "../artifacts-zk/contracts/ZKHTreasurer.sol/ZKHTreasurer.json";

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();
async function main() {
    // Initialize the wallet.1
    const zkWallet = Wallet.fromMnemonic(mnemonic);
    const deployer = new Deployer(hre, zkWallet);
    
    const masterContract = await deployer.loadArtifact("ZKHMaster");
    const zkhToken = "0x8cc3Bb7fc3Ae5fC67cb4cA091610C8309CAF0b24";
    const devAddress = "0x6d2b9b23a5daca4128f04443ef0fccdd71bf9f47"; // Replace with the desired address
    const feeAddress = "0x6d2b9b23a5daca4128f04443ef0fccdd71bf9f47"; // Replace with the desired address
    const treasurerToken = "0xb75B5943084b4452347c1e31f3D0E97E125Ebff6";
    // const sixHoursLater = (await ethers.getDefaultProvider().getBlock('latest')).timestamp + 6 * 60 * 60;
    const args = [zkhToken, devAddress, feeAddress, treasurerToken];

    const beacon = await hre.zkUpgrades.deployBeacon(deployer.zkWallet, masterContract);
    await beacon.deployed();

    const zkhMaster = await hre.zkUpgrades.deployBeaconProxy(deployer.zkWallet, beacon, masterContract, args);
    await zkhMaster.deployed();

    const treasurerContract = new Contract(treasurerToken, treasurerArtifact.abi, zkWallet);
    const tx = await treasurerContract.updateZKHMaster(zkhMaster.address);
    await tx.wait();

    console.log("ZKHMaster address has been updated in the ZKHTreasurer contract");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
