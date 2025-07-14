// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract SendETH {
    function deposit() public payable {}

    function sendViaTransfer(address payable _to, uint _amount) public {
        _to.transfer(_amount); // Esto le mandará exactamente 2300 gas
    }
}
