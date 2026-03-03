// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


import "forge-std/Test.sol";


// INTERFACES

// ERC20 Interface
interface IERC20 {

 function  balanceOf(address account) external view  returns (uint256);

 function approve(address spender, uint256 amount) external returns(bool);
     
} 


// Uniswap V2 Factory Interface
interface IUniswapV2Factory {

    function getPair(address tokenA, address tokenB) external view returns(address pair);
}


// Uniswap V2 Router Interface
interface IUniswapV2Router02 {
    function WETH() external pure returns (address);

    function swapExactETHForTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable returns (uint[] memory amounts);
}




contract UniV2ArchTest is Test {

address constant FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
address constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address WETH;


IUniswapV2Factory factory = IUniswapV2Factory(FACTORY);
IUniswapV2Router02 router = IUniswapV2Router02(ROUTER);
IERC20 usdc = IERC20(USDC);


function setUp() public {

    string memory rpcUrl = vm.envString("MAINNET_RPC_URL");

    uint256 forkBlock = vm.envUint("FORK_BLOCK");

    // vm.createSelectFork(rpcUrl, forkBlock);
    vm.createSelectFork(rpcUrl, forkBlock);
    vm.deal(address(this), 100 ether);
    WETH = router.WETH();
}

function test_fork_runs() public {
    emit log_named_uint("Fork Block Number", block.number);
    emit log_named_address("WETH", WETH);
    assertTrue(block.number > 0);
}




}