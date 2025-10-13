// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/*
    - Anyone can donate to the contract (at least 0.05 eth)
    - Donors are stored in a mapping
    - Anyone can send ETH to any address
    - And want for the cooldown. (24 hrs)
*/

/*  TODO:
    - Use constant for COOLDOWN anda CLAIM_AMOUNT 
    - Force to claime justo for msg.sender (why?) 
        (some one can claime for many addresses and abuse, maybe set a time per msg.sender, like 5)
    - When somebody claim, the have to be registrated into a mapping. 
*/

contract MyFaucet {
    mapping (address => bool) public donor; 
    mapping (address => uint) public coolDown;
    uint32 public constant COOLDOWN = 1 days;
    uint64 public CLAIM_AMOUNT = 0.05 ether;  

    event Sent(address recipient);

    // Anybudy can donete to this contract.    
    function donate() external payable {
        require(msg.value > CLAIM_AMOUNT, "ETH is require an least 0.05 ether.");
        donor[msg.sender] = true;
    }

    // Ask for some eth.
    function claim(address payable recipient) 
        external 
    {   
        require(address(this).balance >= CLAIM_AMOUNT, "Not enough ether in this contract");
        require(recipient != address(0), "Invalid address");
        require(block.timestamp >= coolDown[recipient] + COOLDOWN, "That address recently claimed ETH");

        coolDown[recipient] = block.timestamp; // 1st - up date the state!

        (bool sent, ) = recipient.call{value: CLAIM_AMOUNT}(""); // 2nd - external interaction
        require(sent, "Failed to send ETH");

        emit Sent(recipient); // 3rd - update the state
        
    }

    function doAmICanClaime () 
        external 
        view 
        returns 
    (bool) {        
        return block.timestamp >= coolDown[msg.sender] + COOLDOWN;
    }

    // Allow contract to recive ETH 
    receive() external payable { }
}