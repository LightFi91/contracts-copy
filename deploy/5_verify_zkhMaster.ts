// import { HardhatRuntimeEnvironment } from "hardhat/types";
import * as hre from 'hardhat';

async function main() {
    
    /// zkhTreasurer impl
    await hre.run("verify:verify", {
      address: "0xcDBF67bE47a3184aeaa5CF8D27b2cA101F5e542e",
      contract: "contracts/ZKHTreasurer.sol:ZKHTreasurer",
      constructorArguments: []
    });

    /// zkhTreasurer Beacon Proxy
    await hre.run("verify:verify", {
        address: "0xb75B5943084b4452347c1e31f3D0E97E125Ebff6",
        contract: "contracts/ZKHTreasurer.sol:ZKHTreasurer",
        constructorArguments: []
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
