// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ZKHFactoryProxy is OwnableUpgradeable {
    address internal _implementation;

    function initialize(address initialImplementation) public initializer {
        __Ownable_init();
        _implementation = initialImplementation;
    }

    function upgradeTo(address newImplementation) external onlyOwner {
        _implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

    event Upgraded(address indexed newImplementation);

    fallback() external {
        address impl = _implementation;
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
