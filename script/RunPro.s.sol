 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/prod/FlashLoanPro.sol";

contract RunPro is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address bot = vm.envAddress("BOT_ADDRESS"); // 部署后填这里
        vm.startBroadcast(pk);
        FlashLoanPro(bot).run(50 ether); // 借 50 WETH 起步
        vm.stopBroadcast();
    }
}
