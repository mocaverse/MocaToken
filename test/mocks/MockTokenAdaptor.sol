// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./../../src/MocaTokenAdaptor.sol";

contract MockTokenAdaptor is MocaTokenAdaptor {

    constructor(address token, address layerZeroEndpoint, address delegate, address owner) 
        MocaTokenAdaptor(token, layerZeroEndpoint, delegate, owner) {}   


    function mockLzReceive(Origin calldata _origin, bytes32 _guid, bytes calldata _message, address unnamedAddress, bytes calldata unnamedBytes) public payable {
        _lzReceive(_origin, _guid, _message, unnamedAddress, unnamedBytes);
    }

}