// import { HardhatRuntimeEnvironment } from "hardhat/types";
import * as hre from 'hardhat';

async function main() {
    
    /// ZKHRouter impl
    await hre.run("verify:verify", {
      address: "0xFE544ab7b3A8CB8e2C7Cb71a2AB6570B304C5a73",
      contract: "contracts/ZKHRouter.sol:ZKHRouter",
      constructorArguments: []
    });

    /// ZKHRouter Beacon Proxy
    await hre.run("verify:verify", {
        address: "0x7E424538C883e0Da07F536fe87D9a69886772A02",
        contract: "contracts/ZKHRouter.sol:ZKHRouter",
        constructorArguments: []
    });
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
