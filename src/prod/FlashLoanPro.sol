 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
}

interface IAavePool {
    function flashLoanSimple(
        address receiver,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

contract FlashLoanPro {
    address public immutable owner;
    address public constant AAVE_POOL_SEPOLIA = 0x6ab707Aca953eDAeFB39C3280d0f085423628c18;
    address public constant AAVE_POOL_MAINNET = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    constructor() {
        owner = msg.sender;
    }

    // Aave 真实回调（上线后在这里写 UniswapV3/Balancer/Curve 三角套利）
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address,
        bytes calldata
    ) external returns (bool) {
        require(msg.sender == AAVE_POOL_MAINNET || msg.sender == AAVE_POOL_SEPOLIA, "not aave");

        // TODO: 真实套利逻辑（目前先假装赚 0.8%）
        uint256 profit = amount * 8 / 1000;

        IERC20(asset).approve(msg.sender, amount + premium);
        IERC20(asset).transfer(owner, profit);

        return true;
    }

    // 一键触发（Sepolia 和主网都通用）
    function run(uint256 amount) external {
        require(msg.sender == owner, "not owner");
        address pool = block.chainid == 11155111 
            ? AAVE_POOL_SEPOLIA 
            : AAVE_POOL_MAINNET;

        IAavePool(pool).flashLoanSimple(
            address(this),
            WETH,
            amount,
            "",
            0
        );
    }

    function withdraw(address token) external {
        require(msg.sender == owner);
        IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this)));
    }

    receive() external payable {}
}
