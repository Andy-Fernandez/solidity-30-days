// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;


contract EtherPiggyBank {
    
    mapping (address => uint256) public balances;

    event Received(address indexed sender, uint amount);

    receive() external payable {    
        emit Received(msg.sender, msg.value);
    }

    function deposit() payable external {
        require(msg.value > 0, "Invalid amount");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint _amount) external {
        require(balances[msg.sender] >= _amount, "Insufficient");

        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }
 
}