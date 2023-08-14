import { ethers } from "hardhat";
import { ZKHToken__factory, ZKHTokenProxy__factory } from "../typechain-types";

async function main() {
    const [deployer] = await ethers.getSigners();

    console.log("Deploying contracts with the account:", deployer.address);
    console.log("Account balance:", (await deployer.getBalance()).toString());

    // Deploy the ZKHToken logic contract
    const ZKHTokenFactory = new ZKHToken__factory(deployer);
    const zkhTokenLogic = await ZKHTokenFactory.deploy();
    await zkhTokenLogic.deployed();
    console.log("ZKHToken logic contract deployed to:", zkhTokenLogic.address);

    // Deploy the ZKHTokenProxy contract
    const ZKHTokenProxyFactory = new ZKHTokenProxy__factory(deployer);
    const zkhTokenProxy = await ZKHTokenProxyFactory.deploy();
    await zkhTokenProxy.deployed();
    console.log("ZKHToken proxy contract deployed to:", zkhTokenProxy.address);

    // Initialize the ZKHTokenProxy with the ZKHToken logic contract address
    await zkhTokenProxy.initialize(zkhTokenLogic.address);
    console.log("ZKHTokenProxy initialized with ZKHToken logic address");

    // Initialize the ZKHToken through the proxy
    const zkhToken = ZKHToken__factory.connect(zkhTokenProxy.address, deployer);
    const dev2Address = "0x6d2b9b23a5daca4128f04443ef0fccdd71bf9f47"; // Replace with the desired address
    const feeAddress = "0x6d2b9b23a5daca4128f04443ef0fccdd71bf9f47"; // Replace with the desired address
    const initialMint = ethers.utils.parseEther("9000000"); // Replace with the desired amount
    await zkhToken.initialize(dev2Address, feeAddress, initialMint);
    console.log("ZKHToken initialized through proxy");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
