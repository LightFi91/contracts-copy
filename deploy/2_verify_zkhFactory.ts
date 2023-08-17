// import { HardhatRuntimeEnvironment } from "hardhat/types";
import * as hre from 'hardhat';

async function main() {
    
    const implVerifID = await hre.run("verify:verify", {
      address: "0x21AF3810F612A2A4ecc0D632ACDb7286feae7cA3",
      contract: "contracts/ZKHarvestFactory.sol:ZKHarvestFactory",
      constructorArguments: []
    });
    console.log('contract impl verified : ', implVerifID);

    const beaconVerifID = await hre.run("verify:verify", {
        address: "0x54f8e5fF94a950390d0fBf2C0703036549B5c0F4",
        contract: "contracts/ZKHarvestFactory.sol:ZKHarvestFactory",
        constructorArguments: []
    });
    console.log('contract verified : ', beaconVerifID);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
