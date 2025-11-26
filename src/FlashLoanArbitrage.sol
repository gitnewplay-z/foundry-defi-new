// src/FlashLoanArbitrage.sol  ——  完全零依赖版
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IPool {
    function flashLoanSimple(address receiver, address asset, uint256 amount, bytes calldata params, uint16 referralCode) external;
}

contract FlashLoanArbitrage {
    address public immutable POOL;
    address public owner;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    constructor(address _pool) { POOL = _pool; owner = msg.sender; }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        require(msg.sender == POOL);
        uint256 totalOwed = amount + premium;
        IERC20(asset).approve(POOL, totalOwed);

        // 真实套利写这里（现在先假装赚 1%）
        IERC20(asset).transfer(address(this), amount / 100);

        return true;
    }

    function borrow(uint256 amount) external {
        require(msg.sender == owner);
        IPool(POOL).flashLoanSimple(address(this), DAI, amount, "", 0);
    }

    function withdraw() external {
        require(msg.sender == owner);
        IERC20(DAI).transfer(owner, IERC20(DAI).balanceOf(address(this)));
    }

    receive() external payable {}
}