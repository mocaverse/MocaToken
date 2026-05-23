// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

import {MocaOFT} from "./../../src/MocaOFT.sol";

abstract contract LZState is Script {

    uint16 public baseID = 30101;
    address public baseEP = 0x1a44076050125825900e736c501f859c50fE728c;

    uint16 public homeChainID = baseID;
    address public homeLzEP = baseEP;
}

contract DeployBaseOftDummy is LZState {

    function run() public {

        address deployer = vm.envAddress("PUBLIC_KEY_TEST");
        address delegate = deployer;
        address owner = delegate;

        // deploy OFT
        vm.startBroadcast(vm.envUint("PRIVATE_KEY_TEST"));
            MocaOFT mocaOFT = new MocaOFT("TestOFT", "TEST", homeLzEP, delegate, owner);
        vm.stopBroadcast();
    }
}

// forge script script/MocaChain/BaseOftDummy.s.sol:DeployBaseOftDummy --rpc-url base --broadcast --verify -vvvv --etherscan-api-key base