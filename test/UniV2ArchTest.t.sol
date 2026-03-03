// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import "forge-std/Test.sol";


// INTERFACES

interface IERC20 {

 function  balanceOf(address account) external view  returns (uint256);

 function approve(address spender, uint256 amount) external view returns(bool);
     
} 

interface IUniswapV2Router {

    function getPair(address tokenA, address tokenB) external view returns(address pair);
}

interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[ ] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint [] memory amounts);
}




contract UniV2ArchTest is Test {






}