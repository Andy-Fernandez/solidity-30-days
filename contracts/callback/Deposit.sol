// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract Deposit {
    mapping(address => uint) public balances;

    event Received(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event FallbackTriggered(address indexed sender, uint256 value, bytes data);

    function deposit() external payable {
        require(msg.value > 0, "zero?");
        balances[msg.sender] += msg.value;
        emit Received(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "nope");
        balances[msg.sender] -= amount;
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "transfer fail");
        emit Withdrawn(msg.sender, amount);
    }

    /* callbacks */
    fallback() external payable {
        emit FallbackTriggered(msg.sender, msg.value, msg.data);
    }
    receive() external payable {
        emit FallbackTriggered(msg.sender, msg.value, "");
    }
}



contract Caller {
    function trigger(address victim, bytes calldata data)
        external
        payable
    {
        (bool ok, ) = victim.call{value: msg.value}(data);
        require(ok, "call failed");
    }
}
