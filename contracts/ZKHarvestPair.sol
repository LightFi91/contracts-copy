// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./interface/UQ112x112.sol";
import "./interface/Math.sol";
import "./interface/IZKHarvestPair.sol";
import "./interface/IZKHarvestFactory.sol";
import "./interface/IZKHarvestCallee.sol";
import "./ZKHarvestERC20.sol";

contract ZKHarvestPair is IZKHarvestPair, ZKHarvestERC20, ReentrancyGuard {
    using SafeMath  for uint;
    using UQ112x112 for uint224;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));

    address public factory;
    address public token0;
    address public token1;
    

    uint112 private reserve0;           // uses single storage slot, accessible via getReserves
    uint112 private reserve1;           // uses single storage slot, accessible via getReserves
    uint32  private blockTimestampLast; // uses single storage slot, accessible via getReserves

    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast; // reserve0 * reserve1, as of immediately after the most recent liquidity event

    uint public lpFee = 15 ; //trading fee ratio for lp providers 
    uint public sFee = 10 ; //secondary trading fee
    uint private unlocked = 1;
    
    mapping (address => bool) private _addTaxFree;
    mapping (address => bool) private _removeTaxFree;

    function initialize() override public initializer {
        super.initialize();
        factory = msg.sender;
    }

    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    function getReservesSimple() external view override returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    /*//////////////////////////////////////////////////////////////
    INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _getReserves() private view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }


    function _getBalances(address _token0, address _token1) private view returns (uint, uint) {
        return (
            IERC20(_token0).balanceOf(address(this)),
            IERC20(_token1).balanceOf(address(this))
        );
    }
    
    function setLiqTax(bool token0_Tax , bool token1_tax) external returns(bool) {
        require(msg.sender == IZKHarvestFactory(factory).feeToSetter() , "only zkHarvest Dev allowed");
        _addTaxFree[token0] = token0_Tax;
        _addTaxFree[token1] = token1_tax;
        return(true);
    }
    
    function setRLiqTax(bool token0_Tax , bool token1_tax) external returns(bool) {
        require(msg.sender == IZKHarvestFactory(factory).feeToSetter() , "only zkHarvest Dev allowed");
        _removeTaxFree[token0] = token0_Tax;
        _removeTaxFree[token1] = token1_tax;
        return(true);
    }
    
    function setFees(uint _lpFee , uint _sFee) external returns(bool) {
        require(msg.sender == IZKHarvestFactory(factory).feeToSetter() , "only zkHarvest Dev allowed");
        require(_lpFee.add(_sFee) == 25 , "Total Fee should be 0.25%" );
        lpFee = _lpFee ;
        sFee = _sFee ;
        return(true);
    }
    
    function isAddTaxFree(address token) public view returns(bool ){
        return(_addTaxFree[token]);
    }
    
    function isRemoveTaxFree(address token) public view returns(bool ){
        return(_removeTaxFree[token]);
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'zkHarvest: TRANSFER_FAILED');
    }
    
    function _safeTransferTaxFree(address token, address to, uint value) private {
        // bytes4(keccak256(bytes('transferTaxFree(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xdffc1a11, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    // called once by the factory at time of deployment
    function initialize(address _token0, address _token1) external {
        require(_token0 != address(0) && _token1 != address(0), 'zkHarvest: tokens cannot be the zero address');
        require(msg.sender == factory, 'zkHarvest: FORBIDDEN'); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        // require(balance0 <= uint112(-1) && balance1 <= uint112(-1), 'zkHarvest: OVERFLOW');
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, 'zkHarvest: OVERFLOW');
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) * timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // if fee is on, mint liquidity equivalent to sFee/25 of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IZKHarvestFactory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast)).mul(sFee);
                    uint denominator = rootK.mul(lpFee).add(rootKLast.mul(sFee));
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    // this low-level function should be called from a contract which performs important safety checks
    function mint(address to) external nonReentrant returns (uint liquidity) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
           _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            liquidity = Math.min(amount0.mul(_totalSupply) / _reserve0, amount1.mul(_totalSupply) / _reserve1);
        }
        require(liquidity > 0, 'zkHarvest: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function burn(address to) external nonReentrant returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'zkHarvest: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        
        if(isRemoveTaxFree(_token0)){
            _safeTransferTaxFree(_token0, to, amount0);
        }
        else{
            _safeTransfer(_token0, to, amount0);
        }
        if(isRemoveTaxFree(_token1)){
             _safeTransferTaxFree(_token1, to, amount1);
        }
        else{
             _safeTransfer(_token1, to, amount1);
        }
        
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external nonReentrant {
        require(amount0Out > 0 || amount1Out > 0, 'zkHarvest: INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        require(amount0Out < _reserve0 && amount1Out < _reserve1, 'zkHarvest: INSUFFICIENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        { // scope for _token{0,1}, avoids stack too deep errors
        address _token0 = token0;
        address _token1 = token1;
        require(to != _token0 && to != _token1, 'zkHarvest: INVALID_TO');
        if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
        if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens
        if (data.length > 0) IZKHarvestCallee(to).zkharvestCall(msg.sender, amount0Out, amount1Out, data);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint amount0In = balance0 > _reserve0 - amount0Out ? balance0 - (_reserve0 - amount0Out) : 0;
        uint amount1In = balance1 > _reserve1 - amount1Out ? balance1 - (_reserve1 - amount1Out) : 0;
        require(amount0In > 0 || amount1In > 0, 'zkHarvest: INSUFFICIENT_INPUT_AMOUNT');
        { // scope for reserve{0,1}Adjusted, avoids stack too deep errors
        uint balance0Adjusted = (balance0.mul(10000).sub(amount0In.mul(25)));
        uint balance1Adjusted = (balance1.mul(10000).sub(amount1In.mul(25)));
        require(balance0Adjusted.mul(balance1Adjusted) >= uint(_reserve0).mul(_reserve1).mul(10000**2), 'zkHarvest: K');
        }

        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    function swapFor0(uint amount0Out, address to) external override nonReentrant {
        require(amount0Out > 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1) = _getReserves();
        require(amount0Out < _reserve0, 'INSUFFICIENT_LIQUIDITY');

        address _token0 = token0;
        _safeTransfer(_token0, to, amount0Out);
        (uint balance0After, uint balance1After) = _getBalances(_token0, token1);

        uint amount1In = balance1After - _reserve1;
        require(amount1In != 0, 'INSUFFICIENT_INPUT_AMOUNT');

        // Checks the K.
        uint balance1Adjusted = (balance1After * 10000) - (amount1In.mul(25));
        require(balance0After * balance1Adjusted >= uint(_reserve0) * _reserve1 * 10000, 'K');

        _update(balance0After, balance1After, _reserve0, _reserve1);
        emit Swap(msg.sender, 0, amount1In, amount0Out, 0, to);
    }

    function swapFor1(uint amount1Out, address to) external override nonReentrant {
        require(amount1Out != 0, 'INSUFFICIENT_OUTPUT_AMOUNT');
        (uint112 _reserve0, uint112 _reserve1) = _getReserves();
        require(amount1Out < _reserve1, 'INSUFFICIENT_LIQUIDITY');

        address _token1 = token1;
        _safeTransfer(_token1, to, amount1Out);
        (uint balance0After, uint balance1After) = _getBalances(token0, _token1);

        uint amount0In = balance0After - _reserve0;
        require(amount0In != 0, 'INSUFFICIENT_INPUT_AMOUNT');

        // Checks the K.
        uint balance0Adjusted = (balance0After * 10000) - (amount0In.mul(25));
        require(balance0Adjusted * balance1After >= uint(_reserve0) * _reserve1 * 10000, 'K');

        _update(balance0After, balance1After, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, 0, 0, amount1Out, to);
    }


    // force balances to match reserves
    function skim(address to) external nonReentrant {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        _safeTransfer(_token0, to, IERC20(_token0).balanceOf(address(this)).sub(reserve0));
        _safeTransfer(_token1, to, IERC20(_token1).balanceOf(address(this)).sub(reserve1));
    }

    // force reserves to match balances
    function sync() external nonReentrant {
        _update(IERC20(token0).balanceOf(address(this)), IERC20(token1).balanceOf(address(this)), reserve0, reserve1);
    }

    // Overrides
    function approve(address spender, uint value) external override(IZKHarvestPair, ZKHarvestERC20) returns (bool) {
        return ZKHarvestERC20(this).approve(spender, value);
    }

    function transfer(address to, uint value) external override(IZKHarvestPair, ZKHarvestERC20) returns (bool) {
        return ZKHarvestERC20(this).transfer(to, value);
    }

    function transferFrom(address from, address to, uint value) external override(IZKHarvestPair, ZKHarvestERC20) returns (bool) {
        return ZKHarvestERC20(this).transferFrom(from, to, value);
    }

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external override(IZKHarvestPair, ZKHarvestERC20) {
        ZKHarvestERC20(this).permit(owner, spender, value, deadline, v, r, s);
    }
}
