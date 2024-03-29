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

    function deploymentChainId() public returns(uint256) {
        return _DEPLOYMENT_CHAINID;
    }

    function domainSeparator() public returns (bytes32) {
        return _domainSeparator();
    }

    function makeDomainSeperator(string memory name, string memory version, uint256 chainId) public returns (bytes32) {

        return
            keccak256(
                abi.encode(
                    // keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)")
                    0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f,
                    keccak256(bytes(name)),
                    keccak256(bytes(version)),
                    chainId,
                    address(this)
                )
            );
    }
    
    
    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }

    function mockLzReceive(Origin calldata _origin, bytes32 _guid, bytes calldata _message, address unnamedAddress, bytes calldata unnamedBytes) public payable {
        _lzReceive(_origin, _guid, _message, unnamedAddress, unnamedBytes);
    }

    function credit(address to, uint256 amountLD, uint32 srcEid) public returns (uint256) {
       uint256 amountReceived = _credit(to, amountLD, srcEid);
    }

   function _lzSend(uint32 _dstEid, bytes memory _message, bytes memory _options, MessagingFee memory _fee, address _refundAddress) internal override returns (MessagingReceipt memory receipt) {}

}
