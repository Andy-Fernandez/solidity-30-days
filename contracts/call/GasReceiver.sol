// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GasReceiver {
    event GasReceived(uint gasLeft);

    receive() external payable {
        emit GasReceived(gasleft()); // Emite cuánto gas recibió
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
