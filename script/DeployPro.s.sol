 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/prod/FlashLoanPro.sol";

contract DeployPro is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);
        new FlashLoanPro();
        vm.stopBroadcast();
    }
}
