// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract Counter {
    uint public counter;

    event CounterIncrement(uint newValue);
    event CounterDecrement(uint newValue);

    constructor(uint startNumber) {
      require(startNumber >= 0, "Counter needs a positive starting number");
      counter = startNumber;
    }

    function incrementr() public returns(uint) {
      emit CounterIncrement(counter);
      return counter += 1;
    }

    function decrement() public returns(uint) {
      // we should add and require!
      require(counter > 0 , "Cant decrement less than zero");
      emit CounterDecrement(counter);
      return counter -= 1;
    }
}
