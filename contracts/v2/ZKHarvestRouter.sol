// SPDX-License-Identifier: AGPL-3.0-or-later

pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../lib/ZKHLibrary.sol";
import "../lib/TransferHelper.sol";
import "../interface/IZKHRouter.sol";
import "../interface/IZKHarvestFactory.sol";
import "../interface/IZKHarvestPair.sol";
import "../interface/IZKHEther.sol";

contract ZKHRouter is IZKHRouter, ReentrancyGuard {
  using SafeMath for uint;

  address public override factory;
  address public override WETH;

  struct LiquidityData {
    address tokenA;
    address tokenB;
    uint amountADesired;
    uint amountBDesired;
    uint amountAMin;
    uint amountBMin;
    uint reserveA;
    uint reserveB;
  }

  modifier ensureNotExpired(uint deadline) {
    require(block.timestamp <= deadline, "EXPIRED");
    _;
  }

  constructor(address _factory, address _WETH) {
    factory = _factory;
    WETH = _WETH;
  }


  /// HELPERS

  // Helper function to ensure amounts are correct
  function _ensure(uint[] memory amounts) internal pure returns (uint) {
    require(amounts.length >= 2, "ZKHRouter: INVALID_PATH");
    uint _amounts0 = amounts[0];
    for (uint i; i < amounts.length - 1; i++) {
      require(amounts[i] > 0, "ZKHRouter: INVALID_AMOUNT");
      _amounts0 = _amounts0.mul(amounts[i + 1]) / amounts[i];
    }
    return _amounts0;
  }

  function _calculateAmountsToAdd(
    LiquidityData memory data
  ) internal pure returns (uint amountA, uint amountB) {
    if (data.reserveA == 0 && data.reserveB == 0) {
      return (data.amountADesired, data.amountBDesired);
    }
    uint amountBOptimal = ZKHLibrary.quote(
      data.amountADesired,
      data.reserveA,
      data.reserveB
    );
    if (amountBOptimal <= data.amountBDesired) {
      return (data.amountADesired, amountBOptimal);
    } else {
      uint amountAOptimal = ZKHLibrary.quote(
        data.amountBDesired,
        data.reserveB,
        data.reserveA
      );
      assert(amountAOptimal <= data.amountADesired);
      return (amountAOptimal, data.amountBDesired);
    }
  }

  function _transferTokens(
    address tokenA,
    address tokenB,
    uint amountA,
    uint amountB,
    address to
  ) internal {
    TransferHelper.safeTransferFrom(tokenA, msg.sender, to, amountA);
    TransferHelper.safeTransferFrom(tokenB, msg.sender, to, amountB);
  }

  function _swap(
    uint[] memory amounts,
    address[] memory path,
    address _to
  ) internal {
    for (uint i; i < path.length - 1; i++) {
      (address input, address output) = (path[i], path[i + 1]);
      (address token0, ) = ZKHLibrary.sortTokens(input, output);
      uint amountOut = amounts[i + 1];
      (uint amount0Out, uint amount1Out) = input == token0
        ? (uint(0), amountOut)
        : (amountOut, uint(0));

      address to = i < path.length - 2
        ? ZKHLibrary.pairFor(factory, output, path[i + 2])
        : _to;
      IZKHarvestPair(ZKHLibrary.pairFor(factory, input, output)).swap(
        amount0Out,
        amount1Out,
        to,
        new bytes(0)
      );
    }
  }


  /// LIQUIDITY

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  )
    public
    ensureNotExpired(deadline)
    returns (uint amountA, uint amountB, uint liquidity)
  {
    // Create a pair if it doesn't exist yet
    if (IZKHarvestFactory(factory).getPair(tokenA, tokenB) == address(0)) {
      IZKHarvestFactory(factory).createPair(tokenA, tokenB);
    }
    (uint reserveA, uint reserveB) = ZKHLibrary.getReserves(
      factory,
      tokenA,
      tokenB
    );

    LiquidityData memory data = LiquidityData({
      tokenA: tokenA,
      tokenB: tokenB,
      amountADesired: amountADesired,
      amountBDesired: amountBDesired,
      amountAMin: amountAMin,
      amountBMin: amountBMin,
      reserveA: reserveA,
      reserveB: reserveB
    });

    (uint _amountA, uint _amountB) = _calculateAmountsToAdd(data);
    require(_amountA >= amountAMin, "ZKHRouter: INSUFFICIENT_A_AMOUNT");
    require(_amountB >= amountBMin, "ZKHRouter: INSUFFICIENT_B_AMOUNT");

    _transferTokens(tokenA, tokenB, _amountA, _amountB, to);
    liquidity = IZKHarvestPair(IZKHarvestFactory(factory).getPair(tokenA, tokenB)).mint(to);
    return (_amountA, _amountB, liquidity);
  }

  function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  )
    external
    payable
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint amountToken, uint amountETH, uint liquidity)
  {
    uint amountETHDesired = msg.value;
    IZKHEther(WETH).deposit{value: amountETHDesired}(); // Convert ETH to WETH
    TransferHelper.safeApprove(WETH, address(this), amountETHDesired); // Approve the router to spend WETH

    (amountToken, amountETH, liquidity) = this.addLiquidity(
      token,
      WETH,
      amountTokenDesired,
      amountETHDesired,
      amountTokenMin,
      amountETHMin,
      to,
      deadline
    );

    // Refund any unspent ETH
    uint refundETH = msg.value.sub(amountETH);
    if (refundETH > 0) {
      TransferHelper.safeTransferETH(msg.sender, refundETH);
    }
  }

  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint liquidity,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
  )
    external
    override
    ensureNotExpired(deadline)
    returns (uint amountA, uint amountB)
  {
    address pair = ZKHLibrary.pairFor(factory, tokenA, tokenB);
    IZKHarvestPair(pair).transferFrom(msg.sender, pair, liquidity); // Send liquidity tokens to the pair

    (uint amount0, uint amount1) = IZKHarvestPair(pair).burn(to); // Burn the liquidity tokens and get the underlying assets

    (address token0, ) = ZKHLibrary.sortTokens(tokenA, tokenB);
    (amountA, amountB) = tokenA == token0
      ? (amount0, amount1)
      : (amount1, amount0); // Sort the returned amounts based on the input tokens

    require(amountA >= amountAMin, "ZKHRouter: INSUFFICIENT_A_AMOUNT");
    require(amountB >= amountBMin, "ZKHRouter: INSUFFICIENT_B_AMOUNT");
  }

  function removeLiquidityETH(
    address token,
    uint liquidity,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
  )
    external
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint amountToken, uint amountETH)
  {
    (amountToken, amountETH) = this.removeLiquidity(
      token,
      WETH,
      liquidity,
      amountTokenMin,
      amountETHMin,
      address(this),
      deadline
    );
    TransferHelper.safeTransfer(token, to, amountToken);
    IZKHEther(WETH).withdraw(amountETH);
    TransferHelper.safeTransferETH(to, amountETH);
  }

  /// SWAPS

  function swapExactTokensForTokens(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  )
    external
    override
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint[] memory amounts)
  {
    require(path.length >= 2, "ZKHRouter: INVALID_PATH");

    amounts = ZKHLibrary.getAmountsOut(factory, amountIn, path);
    require(
      amounts[amounts.length - 1] >= amountOutMin,
      "ZKHRouter: INSUFFICIENT_OUTPUT_AMOUNT"
    );

    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      ZKHLibrary.pairFor(factory, path[0], path[1]),
      amounts[0]
    );

    _swap(amounts, path, to);
  }

  function swapExactETHForTokens(
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  )
    external
    payable
    override
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint[] memory amounts)
  {
    require(path[0] == WETH, "ZKHRouter: INVALID_PATH");

    amounts = ZKHLibrary.getAmountsOut(factory, msg.value, path);
    require(
      amounts[amounts.length - 1] >= amountOutMin,
      "ZKHRouter: INSUFFICIENT_OUTPUT_AMOUNT"
    );

    IZKHEther(WETH).deposit{value: amounts[0]}();
    _swap(amounts, path, to);
  }

  function swapExactTokensForETH(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  )
    external
    override
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint[] memory amounts)
  {
    require(path[path.length - 1] == WETH, "ZKHRouter: INVALID_PATH");
    amounts = ZKHLibrary.getAmountsOut(factory, amountIn, path);
    require(
      amounts[amounts.length - 1] >= amountOutMin,
      "ZKHRouter: INSUFFICIENT_OUTPUT_AMOUNT"
    );
    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      ZKHLibrary.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, address(this));
    IZKHEther(WETH).withdraw(amounts[amounts.length - 1]);
    TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
  }

  function swapTokensForExactETH(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  )
    external
    override
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint[] memory amounts)
  {
    require(path[path.length - 1] == WETH, "ZKHRouter: INVALID_PATH");

    amounts = ZKHLibrary.getAmountsIn(factory, amountOut, path);
    require(amounts[0] <= amountInMax, "ZKHRouter: EXCESSIVE_INPUT_AMOUNT");
    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      ZKHLibrary.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, address(this));
    IZKHEther(WETH).withdraw(amounts[amounts.length - 1]);
    TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
  }

  function swapExactTokensForTokensWithFee(
    uint amountIn,
    uint amountOutMin,
    address[] calldata path,
    address to,
    uint deadline
  )
    external
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint[] memory amounts)
  {
    amounts = ZKHLibrary.getAmountsOut(factory, amountIn, path);
    require(
      amounts[amounts.length - 1] >= amountOutMin,
      "ZKHRouter: INSUFFICIENT_OUTPUT_AMOUNT"
    );

    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      ZKHLibrary.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swapSupportingFeeOnTransferTokens(amounts, path, to);
  }

  function _swapSupportingFeeOnTransferTokens(
    uint[] memory amounts,
    address[] memory path,
    address _to
  ) internal {
    for (uint i = 0; i < path.length - 1; i++) {
      (address input, address output) = (path[i], path[i + 1]);
      IZKHarvestPair pair = IZKHarvestPair(
        ZKHLibrary.pairFor(factory, input, output)
      );
      uint amountInput = amounts[i];
      uint amountOutputExpected = amounts[i + 1];
      uint amountOutputActual;
      {
        (uint reserveInput, uint reserveOutput) = ZKHLibrary.getReserves(
          factory,
          input,
          output
        );
        amountOutputActual = ZKHLibrary.getAmountOut(
          amountInput,
          reserveInput,
          reserveOutput
        );
      }
      require(
        amountOutputActual >= amountOutputExpected,
        "ZKHRouter: INSUFFICIENT_OUTPUT_AMOUNT"
      );
      (uint amount0Out, uint amount1Out) = input == pair.token0()
        ? (uint(0), amountOutputActual)
        : (amountOutputActual, uint(0));
      pair.swap(amount0Out, amount1Out, _to, new bytes(0));
    }
  }


  function swapTokensForExactTokens(
    uint amountOut,
    uint amountInMax,
    address[] calldata path,
    address to,
    uint deadline
  )
    external
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint[] memory amounts)
  {
    require(path.length >= 2, "ZKHRouter: INVALID_PATH");

    amounts = ZKHLibrary.getAmountsIn(factory, amountOut, path);
    require(amounts[0] <= amountInMax, "ZKHRouter: EXCESSIVE_INPUT_AMOUNT");

    TransferHelper.safeTransferFrom(
      path[0],
      msg.sender,
      ZKHLibrary.pairFor(factory, path[0], path[1]),
      amounts[0]
    );
    _swap(amounts, path, to);
  }

  function swapETHForExactTokens(
    uint amountOut,
    address[] calldata path,
    address to,
    uint deadline
  )
    external
    payable
    ensureNotExpired(deadline)
    nonReentrant
    returns (uint[] memory amounts)
  {
    require(path[0] == WETH, "ZKHRouter: INVALID_PATH");

    amounts = ZKHLibrary.getAmountsIn(factory, amountOut, path);
    require(amounts[0] <= msg.value, "ZKHRouter: EXCESSIVE_INPUT_AMOUNT");

    IZKHEther(WETH).deposit{value: amounts[0]}();
    _swap(amounts, path, to);

    // Refund any unspent ETH
    uint refundETH = msg.value.sub(amounts[0]);
    if (refundETH > 0) {
      TransferHelper.safeTransferETH(msg.sender, refundETH);
    }
  }

  function _permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal {
    IZKHarvestPair(owner).permit(owner, spender, value, deadline, v, r, s);
  }

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB) {
    _permit(msg.sender, address(this), liquidity, deadline, v, r, s);
    return
      this.removeLiquidity(
        tokenA,
        tokenB,
        liquidity,
        amountAMin,
        amountBMin,
        to,
        deadline
      );
  }

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH) {
    _permit(msg.sender, address(this), liquidity, deadline, v, r, s);
    return
      this.removeLiquidityETH(
        token,
        liquidity,
        amountTokenMin,
        amountETHMin,
        to,
        deadline
      );
  }

  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    nonReentrant
    ensureNotExpired(deadline)
    returns (uint256 amountETH)
  {
    (uint256 amountToken, uint256 _amountETH) = this.removeLiquidity(
      token,
      WETH,
      liquidity,
      amountTokenMin,
      amountETHMin,
      address(this),
      deadline
    );
    TransferHelper.safeTransfer(token, to, amountToken);
    IZKHEther(WETH).withdraw(_amountETH);
    amountETH = address(this).balance;
    TransferHelper.safeTransferETH(to, amountETH);
  }

  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH) {
    _permit(msg.sender, address(this), liquidity, deadline, v, r, s);
    return
      this.removeLiquidityETHSupportingFeeOnTransferTokens(
        token,
        liquidity,
        amountTokenMin,
        amountETHMin,
        to,
        deadline
      );
  }
}
