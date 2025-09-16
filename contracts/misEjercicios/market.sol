// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract decentraliceMarketplace {
    mapping (address => uint) public owners;

    event DepositoRealizado(address indexed _from, uint _value);

    function depositarAlContrato() public payable {
        require(msg.value > 0, "Debes enviar algo de ETH");
        owners[msg.sender] += msg.value;
        emit DepositoRealizado(msg.sender, msg.value);
    }
}
