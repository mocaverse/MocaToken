// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "./../../src/MocaOFT.sol";

contract MocaOFTMock is MocaOFT {


    /**
     * @param _name token name
     * @param _symbol token symbol
     * @param _lzEndpoint LayerZero Endpoint address
     * @param _delegate The address capable of making OApp configurations inside of the endpoint.
     * @param _owner token owner
     */
    constructor(string memory _name, string memory _symbol, address _lzEndpoint, address _delegate, address _owner) 
        MocaOFT(_name, _symbol, _lzEndpoint, _delegate, _owner){
        
    } 

    
    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }

}