// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// 手动写一个极简 IERC20，只用于本地测试（正式部署时换成 OpenZeppelin 的）
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IPool {
    function flashLoanSimple(
        address receiver,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

contract FlashLoanArbitrage {
    address public immutable POOL;
    address public owner;

    constructor(address _pool) {
        POOL = _pool;
        owner = msg.sender;
    }

    // 外部调用入口
    function startFlashLoan(address asset, uint256 amount) external {
        require(msg.sender == owner, "not owner");
        IPool(POOL).flashLoanSimple(address(this), asset, amount, "", 0);
    }

    // Aave V3 要求的回调函数
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        require(msg.sender == POOL, "not pool");
        require(initiator == address(this), "not initiator");

        // 这里写你的真实套利逻辑
        // 现在先留空，测试能跑就行

        // 归还本金 + 0.09% 费用
        IERC20(asset).approve(POOL, amount + premium);
        return true;
    }

    // 方便测试提取资金
    function withdraw(address token) external {
        require(msg.sender == owner, "not owner");
        IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this)));
    }

    receive() external payable {}
}
