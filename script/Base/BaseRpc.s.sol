// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {MockERC20} from "./../../lib/forge-std/src/mocks/MockERC20.sol";
import "forge-std/Script.sol";

contract BaseRpc is Script {

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TEST");
        vm.startBroadcast(deployerPrivateKey);

        MockERC20 mockERC20 = new MockERC20();
        mockERC20.initialize("MockERC20", "MCK", 18);

        vm.stopBroadcast();
    }
}

// forge script script/Base/BaseRpc.s.sol:BaseRpc --rpc-url base --broadcast --verify -vvvv --etherscan-api-key base