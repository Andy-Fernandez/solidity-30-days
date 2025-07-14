// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SendETH {
    function deposit() public payable {
    }

    // Esta función transfiere diner del contrato a otra wallet
    function sendViaTransfer(address payable _address, uint _amount) public {
        _address.transfer(_amount);
    }
}