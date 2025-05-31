// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Counter {
    uint public counter;

    constructor(uint startNumber) public {
      counter = startNumber;
    }

    function addCounter() public returns(uint) {
      return counter += 1;
    }
}
