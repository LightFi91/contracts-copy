// import { HardhatRuntimeEnvironment } from "hardhat/types";
import * as hre from 'hardhat';
import { Wallet, utils } from "zksync-web3";
import { Deployer } from '@matterlabs/hardhat-zksync-deploy';
import * as ye from "@matterlabs/hardhat-zksync-upgradable"; // important to keep, without this `.zkUpgrades` property would not be visible, for some reason.

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();
async function main() {
    // Initialize the wallet.1
    const zkWallet = Wallet.fromMnemonic(mnemonic);
    const deployer = new Deployer(hre, zkWallet);

    const treasurerContract = await deployer.loadArtifact("ZKHTreasurer");
    const zkhToken = "0x8cc3Bb7fc3Ae5fC67cb4cA091610C8309CAF0b24";
    const lockedRewardsBP = 500;
    const expressClaimBurn = 500;
    const lockupTimeW = 4;
    const args = [zkhToken, lockedRewardsBP, expressClaimBurn, lockupTimeW];

    const beacon = await hre.zkUpgrades.deployBeacon(deployer.zkWallet, treasurerContract);
    await beacon.deployed();

    const zkhTreasurer = await hre.zkUpgrades.deployBeaconProxy(deployer.zkWallet, beacon, treasurerContract, args);
    await zkhTreasurer.deployed();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
