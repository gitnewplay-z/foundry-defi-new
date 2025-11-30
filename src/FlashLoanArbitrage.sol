// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface IERC20 {
    function balanceOf(address) external view returns (uint256);
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

// 模拟 ERC20（在 Mock 环境里可以 mint）
interface IMockToken is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract FlashLoanArbitrage {
    address public immutable POOL;
    address public owner;

    constructor(address _pool) {
        POOL = _pool;
        owner = msg.sender;
    }

    function startFlashLoan(address asset, uint256 amount) external {
        require(msg.sender == owner, "not owner");
        IPool(POOL).flashLoanSimple(address(this), asset, amount, "", 0);
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address,
        bytes calldata
    ) external returns (bool) {
        require(msg.sender == POOL);

        // 重磅：假套利，直接给自己多 mint 10 个 token（真实套利就是这里赚的）
        IMockToken(asset).mint(address(this), 10 ether);

        // 正常归还本金 + 0.09% 费用
        IERC20(asset).approve(POOL, amount + premium);
        return true;
    }

    function withdraw(address token) external {
        require(msg.sender == owner);
        IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this)));
    }
}
