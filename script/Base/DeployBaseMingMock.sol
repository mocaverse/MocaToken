// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {MocaTokenMock} from "./../../test/mocks/MocaTokenMock.sol";
import {MocaOFT} from "./../../src/MocaOFT.sol";
import {MocaTokenAdapter} from "./../../src/MocaTokenAdapter.sol";

import {LZTestnets} from "../LZEndpoints.sol";

import "forge-std/Script.sol";

/** 
    note: eth: home, base: remote
    this test uses MockMocaToken for free mints

    it relies on a prior sepolia deployment of the token and adaptor.
*/

abstract contract LZState is LZTestnets {

    function setUp() public {

        homeChainID = sepoliaID;
        homeLzEP = sepoliaEP;
        
        remoteChainID = baseSepoliaID;
        remoteLzEP = baseSepoliaEP;

        DEPLOYER_ADDRESS = vm.envAddress("PUBLIC_KEY_TEST");
    }
}


contract DeployHome is LZState {

    function run() public broadcast("PRIVATE_KEY_TEST") {

        address mocaTokenAddress = address(0x5667424802Ef74C314e7adbBa6fA669999d8137D);
        address delegate = DEPLOYER_ADDRESS;
        address owner = DEPLOYER_ADDRESS;

        MocaTokenAdapter mocaTokenAdapter = new MocaTokenAdapter(mocaTokenAddress, homeLzEP, delegate, owner);
    }
}
// forge script script/Base/DeployBaseMingMock.sol:DeployHome --rpc-url sepolia --broadcast --verify -vvvv --etherscan-api-key sepolia

//Remote
contract DeployElsewhere is LZState {

    function run() public broadcast("PRIVATE_KEY_TEST") {
        
        console2.log("deployerAddress", DEPLOYER_ADDRESS);

        //params
        string memory name = "TestToken"; 
        string memory symbol = "TT";
        address delegate = DEPLOYER_ADDRESS;
        address owner = DEPLOYER_ADDRESS;

        MocaOFT remoteOFT = new MocaOFT(name, symbol, remoteLzEP, delegate, owner);
    }
}

// forge script script/Base/DeployBaseMingMock.sol:DeployElsewhere --rpc-url base_sepolia --broadcast --verify -vvvv --etherscan-api-key base_sepolia

// note: update addresses in State
abstract contract State is LZState {
    
    // home: note uses MocaTokenMock for free mints 
    address public mocaTokenAddress = address(0x5667424802Ef74C314e7adbBa6fA669999d8137D);    
    address public mocaTokenAdapterAddress = address(0x03f78AF82816a4fa4E976Aad07319aB7A3bDc889);                     

    // remote
    address public mocaOFTAddress = address(0x012fA6C1295278F922D8ca0C5c770cf32dDDbF26);

    // set contracts
    MocaTokenMock public mocaToken = MocaTokenMock(mocaTokenAddress);
    MocaTokenAdapter public mocaTokenAdapter = MocaTokenAdapter(mocaTokenAdapterAddress);

    MocaOFT public mocaOFT = MocaOFT(mocaOFTAddress);
}


// ------------------------------------------- Trusted Remotes: connect contracts -------------------------
contract SetRemoteOnHome is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {
        // eid: The endpoint ID for the destination chain the other OFT contract lives on
        // peer: The destination OFT contract address in bytes32 format
        bytes32 peer = bytes32(uint256(uint160(address(mocaOFTAddress))));
        mocaTokenAdapter.setPeer(remoteChainID, peer);
    }
}

// forge script script/Base/DeployBaseMingMock.sol:SetRemoteOnHome --rpc-url sepolia --broadcast -vvvv 

contract SetRemoteOnAway is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {
        // eid: The endpoint ID for the destination chain the other OFT contract lives on
        // peer: The destination OFT contract address in bytes32 format
        bytes32 peer = bytes32(uint256(uint160(address(mocaTokenAdapterAddress))));
        mocaOFT.setPeer(homeChainID, peer);
        
    }
}

// forge script script/Base/DeployBaseMingMock.sol:SetRemoteOnAway --rpc-url base_sepolia --broadcast -vvvv 

// ------------------------------------------- Gas Limits -------------------------

import { IOAppOptionsType3, EnforcedOptionParam } from "node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/interfaces/IOAppOptionsType3.sol";

contract SetGasLimitsHome is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {
        
        EnforcedOptionParam memory enforcedOptionParam;
        // msgType:1 -> a standard token transfer via send()
        // options: -> A typical lzReceive call will use 200000 gas on most EVM chains         
        EnforcedOptionParam[] memory enforcedOptionParams = new EnforcedOptionParam[](2);
        enforcedOptionParams[0] = EnforcedOptionParam(remoteChainID, 1, hex"00030100110100000000000000000000000000030d40");
        
        // block sendAndCall: createLzReceiveOption() set gas:0 and value:0 and index:0
        enforcedOptionParams[1] = EnforcedOptionParam(remoteChainID, 2, hex"000301001303000000000000000000000000000000000000");

        mocaTokenAdapter.setEnforcedOptions(enforcedOptionParams);
    }
}

// forge script script/Base/DeployBaseMingMock.sol:SetGasLimitsHome --rpc-url sepolia --broadcast -vvvv 

contract SetGasLimitsAway is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {

        EnforcedOptionParam memory enforcedOptionParam;
        // msgType:1 -> a standard token transfer via send()
        // options: -> A typical lzReceive call will use 200000 gas on most EVM chains 
        EnforcedOptionParam[] memory enforcedOptionParams = new EnforcedOptionParam[](2);
        enforcedOptionParams[0] = EnforcedOptionParam(homeChainID, 1, hex"00030100110100000000000000000000000000030d40");
        
        // block sendAndCall: createLzReceiveOption() set gas:0 and value:0 and index:0
        enforcedOptionParams[1] = EnforcedOptionParam(homeChainID, 2, hex"000301001303000000000000000000000000000000000000");

        mocaOFT.setEnforcedOptions(enforcedOptionParams);
    }
}

// forge script script/Base/DeployBaseMingMock.sol:SetGasLimitsAway --rpc-url base_sepolia --broadcast -vvvv 

// ------------------------------------------- Set Rate Limits  -----------------------------------------

contract SetRateLimitsHome is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {
        
        mocaTokenAdapter.setOutboundLimit(remoteChainID, 100_000_000 ether);
        mocaTokenAdapter.setInboundLimit(remoteChainID, 100_000_000 ether);
    }
}

// forge script script/Base/DeployBaseMingMock.sol:SetRateLimitsHome --rpc-url sepolia --broadcast -vvvv 

contract SetRateLimitsRemote is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {

        mocaOFT.setOutboundLimit(homeChainID, 100_000_000 ether);
        mocaOFT.setInboundLimit(homeChainID, 100_000_000 ether);
    }
}

// forge script script/Base/DeployBaseMingMock.sol:SetRateLimitsRemote --rpc-url base_sepolia --broadcast -vvvv 

// ------------------------------------------- Whitelisting Treasury  -----------------------------------------

import "node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { MessagingParams, MessagingFee, MessagingReceipt } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

contract whitelistTreasuryOnHome is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {
        
        address treasuryMultiSig = DEPLOYER_ADDRESS;
        mocaTokenAdapter.setWhitelist(treasuryMultiSig, true);
    }
}

// forge script script/Base/DeployBaseMingMock.sol:whitelistTreasuryOnHome --rpc-url sepolia --broadcast -vvvv 


contract whitelistTreasuryOnRemote is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {
        
        address treasuryMultiSig = DEPLOYER_ADDRESS;
        mocaOFT.setWhitelist(treasuryMultiSig, false);
    }
}

// forge script script/Base/DeployBaseMingMock.sol:whitelistTreasuryOnRemote --rpc-url base_sepolia --broadcast -vvvv 


// ------------------------------------------- Send sum tokens  -------------------------

// SendParam
import "node_modules/@layerzerolabs/lz-evm-oapp-v2/contracts/oft/interfaces/IOFT.sol";
import { MessagingParams, MessagingFee, MessagingReceipt } from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroEndpointV2.sol";

contract SendTokensToAway is State {

    function run() public broadcast("PRIVATE_KEY_TEST")  {

        //set approval for adaptor to spend tokens
        mocaToken.approve(mocaTokenAdapterAddress, 1 ether);
        
        bytes memory nullBytes = new bytes(0);
        SendParam memory sendParam = SendParam({
            dstEid: remoteChainID,
            to: bytes32(uint256(uint160(address(DEPLOYER_ADDRESS)))),
            amountLD: 1 ether,
            minAmountLD: 1 ether,
            extraOptions: nullBytes,
            composeMsg: nullBytes,
            oftCmd: nullBytes
        });

        // Fetching the native fee for the token send operation
        MessagingFee memory messagingFee = mocaTokenAdapter.quoteSend(sendParam, false);

        // send tokens xchain
        mocaTokenAdapter.send{value: messagingFee.nativeFee}(sendParam, messagingFee, payable(DEPLOYER_ADDRESS));
    }
}

//  forge script script/Base/DeployBaseMingMock.sol:SendTokensToAway --rpc-url sepolia --broadcast -vvvv

contract SendTokensToRemotePlusGas is State {

    function run() public broadcast("PRIVATE_KEY_TEST") {

        //set approval for adaptor to spend tokens
        mocaToken.approve(mocaTokenAdapterAddress, 1 ether);
        
        // createLzNativeDropOption
        // gas: 6000000000000000 (amount of native gas to drop in wei)
        // receiver: 0x000000000000000000000000de05a1abb121113a33eed248bd91ddc254d5e9db (address in bytes32)
        bytes memory extraOptions = hex"0003010031020000000000000000001550f7dca70000000000000000000000000000de05a1abb121113a33eed248bd91ddc254d5e9db";

        bytes memory nullBytes = new bytes(0);
        SendParam memory sendParam = SendParam({
            dstEid: remoteChainID,                                                                  // Destination endpoint ID.
            to: bytes32(uint256(uint160(DEPLOYER_ADDRESS))),     // Recipient address.
            amountLD: 1 ether,                                                                      // Amount to send in local decimals        
            minAmountLD: 1 ether,                                                                   // Minimum amount to send in local decimals.
            extraOptions: extraOptions,                                                             // Additional options supplied by the caller to be used in the LayerZero message.
            composeMsg: nullBytes,                                                               // The composed message for the send() operation.
            oftCmd: nullBytes                                                                    // The OFT command to be executed, unused in default OFT implementations.
        });

        // Fetching the native fee for the token send operation
        MessagingFee memory messagingFee = mocaTokenAdapter.quoteSend(sendParam, false);

        // send tokens xchain
        mocaTokenAdapter.send{value: messagingFee.nativeFee}(sendParam, messagingFee, payable(DEPLOYER_ADDRESS));

    }
}

//  forge script script/Base/DeployBaseMingMock.sol:SendTokensToRemotePlusGas --rpc-url sepolia --broadcast -vvvv