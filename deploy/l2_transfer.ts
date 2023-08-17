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

    // const deploymentFee = await deployer.estimateDeployFee(tokenContract, []);


    // ⚠️ OPTIONAL: You can skip this block if your account already has funds in L2
    // Deposit funds to L2
    const depositHandle = await deployer.zkWallet.deposit({
        to: deployer.zkWallet.address,
        token: utils.ETH_ADDRESS,
        amount: ehters.utils.parseEther("0.8"),
    });
    // Wait until the deposit is processed on zkSync
    await depositHandle.wait();
    console.log("deposited 0.8 to L2");

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
