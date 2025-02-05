// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IERC20} from "./../../lib/forge-std/src/interfaces/IERC20.sol";

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TransferMoca is Script {

    IERC20 public mocaToken = IERC20(0xF944e35f95E819E752f3cCB5Faf40957d311e8c5);    

    function run() public {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_ACTUAL");
        vm.startBroadcast(deployerPrivateKey);

        uint256 balance = mocaToken.balanceOf(0x84Db3d1de9a43Aa144C21b248AD31a1c83d8334D);
        console2.log("balance", balance);

        assert(balance == 10 ether);

        mocaToken.transfer(0x1dB823a15eB4Ad259A8fcEaE3826d89AAaEd33a3, 10 ether);


        vm.stopBroadcast();
    }
}

// forge script script/Base/TransferMoca.s.sol:TransferMoca --rpc-url mainnet