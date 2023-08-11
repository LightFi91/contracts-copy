// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import "../interface/IZKHarvestFactory.sol";
import "../interface/IZKHarvestPair.sol";
import "./ZKHarvestPair.sol";

contract ZKHarvestFactory is IZKHarvestFactory {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(ZKHarvestPair).creationCode));

    address public feeTo;
    address public feeToSetter;

    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    constructor(address _feeToSetter , address _feeTo) {
        require(_feeToSetter != address(0), 'zkHarvest: feeToSetter cannot be the zero address');
        feeToSetter = _feeToSetter;
        feeTo = _feeTo;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function getPairSalt(address _tokenA, address _tokenB) external pure returns (bytes32) {
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        return keccak256(abi.encodePacked(token0, token1));
    }

    function createPair(address tokenA, address tokenB) external returns (address pair) {
        require(tokenA != tokenB, 'zkHarvest: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'zkHarvest: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'zkHarvest: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(ZKHarvestPair).creationCode;
        bytes32 salt = this.getPairSalt(tokenA, tokenB);
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IZKHarvestPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'zkHarvest: FORBIDDEN');
        require(_feeTo != address(0), 'zkHarvest: feeTo cannot be the zero address');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'zkHarvest: FORBIDDEN');
        require(_feeToSetter != address(0), 'zkHarvest feeToSetter cannot be the zero address');
        feeToSetter = _feeToSetter;
    }
}