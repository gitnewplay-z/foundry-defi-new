pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/FlashLoanArbitrage.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;
    function mint(address to, uint256 amount) external { balanceOf[to] += amount; }
    function transfer(address, uint256) external pure returns (bool) { return true; }
    function approve(address, uint256) external pure returns (bool) { return true; }
}

contract MockPool {
    MockToken public token;

    constructor() {
        token = new MockToken();
    }

    function flashLoanSimple(
        address receiver,
        address asset,
        uint256 amount,
        bytes calldata,
        uint16
    ) external {
        require(asset == address(token), "wrong asset");
        token.mint(receiver, amount);

        uint256 premium = amount * 9 / 10000;

        FlashLoanArbitrage(payable(receiver)).executeOperation(
            asset, amount, premium, receiver, ""
        );

        require(token.balanceOf(receiver) >= amount + premium, "loan not repaid");
    }
}

contract FlashLoanLocalTest is Test {
    FlashLoanArbitrage arb;
    MockPool pool;
    MockToken token;

    address owner = address(0xBEEF);

    function setUp() public {
        vm.startPrank(owner);               // 改成这行！永久 prank
        pool = new MockPool();
        token = pool.token();
        arb = new FlashLoanArbitrage(address(pool));
        token.mint(address(arb), 100 ether);
        vm.stopPrank();                     // 部署完结束
    }

    function testFlashLoanSucceeds() public {
        uint256 borrowAmount = 1000 ether;

        console.log("Balance before:", token.balanceOf(address(arb)) / 1e18);

        vm.prank(owner);                    // 再次 prank 调用
        arb.startFlashLoan(address(token), borrowAmount);

        console.log("Balance after :", token.balanceOf(address(arb)) / 1e18);
    }
}
