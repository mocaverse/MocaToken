// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";

import {MocaTokenAdapter} from "./../../src/MocaTokenAdapter.sol";
import {MocaTokenMock} from "./../../test/mocks/MocaTokenMock.sol";

interface IToken {
    function mint(uint256 amount) external;
    function approve(address spender, uint256 amount) external; 
}

/**
    Objective:
        - deploy token and adapter on mainnet
        - deploy OFT on mainnet
    
    For pairing with MocaNativeBridge on MocaChain, as part of mainnet dry-run deployment testing.
*/

abstract contract LZState is Script {
    
    uint16 public ethereumID = 30101;
    address public ethereumEP = 0x1a44076050125825900e736c501f859c50fE728c;
    
    uint16 public mocaID = 30404;
    address public mocaEP = 0x6F475642a6e85809B1c36Fa62763669b1b48DD5B;

    uint16 public homeChainID = ethereumID;
    address public homeLzEP = ethereumEP;

    uint16 public remoteChainID = mocaID;
    address public remoteLzEP = mocaEP;

    address public DEPLOYER_ADDRESS = address(0x8C9C001F821c04513616fd7962B2D8c62f925fD2); // PUBLIC_KEY_TEST
    address public OWNER_ADDRESS = address(0x12Ae960f4CD5448f6B8Da94578Fcf50dB6fa0D1E);    // mocatestnet

    //TODO: sets deployer private key 
    modifier broadcast() {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TEST");
        vm.startBroadcast(deployerPrivateKey);

        _;

        vm.stopBroadcast();
    }
}

//------------------------------ DEPLOY TOKEN + ADAPTER ------------------------------------

contract DeployToken is LZState {

    function run() public broadcast {
        
        // params
        string memory name = "TEST";
        string memory symbol = "TEST";

        // deploy token
        MocaTokenMock mocaToken = new MocaTokenMock(name, symbol, OWNER_ADDRESS);

        console2.log("mocaToken address", address(mocaToken));
    }
}

// forge script script/MocaChain/DryrunMainnet.s.sol:DeployToken --rpc-url mainnet --broadcast --verify -vvvv --etherscan-api-key mainnet

contract DeployAdapter is LZState {

    function run() public broadcast {
        
        // params
        address testTokenAddress = address(0x626CE371088Ba54200f173f1bCA40Fe650bbE70B);

        // deploy adapter
        MocaTokenAdapter mocaTokenAdapter = new MocaTokenAdapter(testTokenAddress, homeLzEP, OWNER_ADDRESS, OWNER_ADDRESS);

        console2.log("mocaTokenAdapter address", address(mocaTokenAdapter));
    }
}

// forge script script/MocaChain/DryrunMainnet.s.sol:DeployAdapter --rpc-url mainnet --broadcast --verify -vvvv --etherscan-api-key mainnet

contract TransferGas is LZState {

    function run() public payable broadcast {
        
        address payable recipient = payable(OWNER_ADDRESS);

        uint256 amount = 0.1 ether; // set the amount to transfer; adjust as needed
        require(address(DEPLOYER_ADDRESS).balance >= amount, "Insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "ETH transfer failed");

        console2.log("Transferred", amount, "wei to", recipient);
    }
}

// forge script script/MocaChain/DryrunMainnet.s.sol:TransferGas --rpc-url mainnet --broadcast -vvvv --etherscan-api-key mainnet 