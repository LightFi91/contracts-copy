// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IZKHToken is IERC20 {
    function burn(uint256 amount) external;
    function mint(address _to, uint256 _amount) external returns (bool);
    function transferOwnership(address newOwner) external;
}