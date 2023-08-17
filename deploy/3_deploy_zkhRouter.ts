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

    const routerContract = await deployer.loadArtifact("ZKHRouter");
    const zkhFactoryAddress = "0x0401071C953110Be960d1CFc36765a1E3f05863B";
    const WETHAddress = "0x20b28B1e4665FFf290650586ad76E977EAb90c5D";
    const args = [zkhFactoryAddress, WETHAddress];

    const beacon = await hre.zkUpgrades.deployBeacon(deployer.zkWallet, routerContract);
    await beacon.deployed();

    const ZKHRouter = await hre.zkUpgrades.deployBeaconProxy(deployer.zkWallet, beacon, routerContract, args);
    await ZKHRouter.deployed();
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
