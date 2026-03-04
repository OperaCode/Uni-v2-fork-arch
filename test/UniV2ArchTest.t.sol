// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";

// INTERFACES

// ERC20 Interface
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);
}

// Uniswap V2 Factory Interface
interface IUniswapV2Factory {
    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);
}

// Uniswap V2 Pair Interface
interface IUniswapV2Pair{
    function token0() external view returns (address);
    function token1() external view returns(address);
    function getReserves( )external view returns(uint112 reserve0,uint112 reserve1, uint32 blockTimestampLast);
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

    // setup function to create the fork and set the WETH address(ROUTER)
    function setUp() public {
        string memory rpcUrl = vm.envString("MAINNET_RPC_URL");

        uint256 forkBlock = vm.envUint("FORK_BLOCK");

        // vm.createSelectFork(rpcUrl, forkBlock);
        vm.createSelectFork(rpcUrl, forkBlock);
        vm.deal(address(this), 100 ether);
        WETH = router.WETH();
    }

    // first test to ensure the fork is working and we can access the WETH address (FACTORY)
    function test_fork_runs() public {
        emit log_named_uint("Fork Block Number", block.number);
        emit log_named_address("WETH", WETH);
        assertTrue(block.number > 0);
    }


    // test to ensure the factory can find the WETH/USDC pair
    function test_factory_finds_pair() public {
        address pair = factory.getPair(WETH, USDC);
        emit log_named_address("WETH/USDC Pair", pair);
        assertTrue(pair != address(0));
    }



    // test to check the reserves of the WETH/USDC pair - if liquidity is present.
    function test_pair_reserves() public {
        address pairAddress = factory.getPair(WETH, USDC);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        (uint112 reserve0, uint112 reserve1, ) = pair.getReserves();

        emit log_named_address("token0", pair.token0());
        emit log_named_address("token1", pair.token1());
        emit log_named_uint("reserve0", reserve0);
        emit log_named_uint("reserve1", reserve1);

        assertTrue(reserve0 > 0 && reserve1 > 0);
    }


    function test_swap_eth_for_usdc()public {
        address pairAddress = factory.getPair(WETH, USDC);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);

        // reserves before the swap
        (uint112 reserve0Before, uint112 reserve1Before, ) = pair.getReserves();


        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = USDC;

        uint deadline = block.timestamp + 1 hours;

        router.swapExactETHForTokens{value : 1 ether}(0, path, address(this),deadline);

        // reserves after
        (uint112 reserve0After, uint112 reserve1After,) = pair.getReserves();

        emit log_named_uint("USDC reserve before (reserve 0)", reserve0Before);
        emit log_named_uint("WETH reserve before (reserve 1)", reserve1Before);

        emit log_named_uint("USDC reserve after (reserve 0)", reserve0After);
        emit log_named_uint("WETH reserve after (reserve 1)", reserve1After);

        // If token0 is USDC and token1 is WETH:
    // Buying USDC means USDC reserve decreases, WETH reserve increases
    assertTrue(reserve0After < reserve0Before, "USDC reserve should go DOWN");
    assertTrue(reserve1After > reserve1Before, "WETH reserve should go UP");

        

        
    }






}
