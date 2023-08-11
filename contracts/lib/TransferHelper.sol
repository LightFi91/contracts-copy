// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.17;

import '../interface/IZKHarvestERC20.sol'; // Assuming you have an ERC20 interface for ZKHarvest

library TransferHelper {
    // Safely transfers tokens and reverts on failure
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IZKHarvestERC20(token).transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    // Safely transfers tokens from a specific address and reverts on failure
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IZKHarvestERC20(token).transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    // Safely transfer ETH fron the contract to the specified address and reverts on failure
    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value: value}(new bytes(0));
        require(success, "TransferHelper: ETH_TRANSFER_FAILED");
    }

    // Safely approves tokens for a specific address and reverts on failure
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IZKHarvestERC20(token).approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }
}
