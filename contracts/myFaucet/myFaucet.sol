// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MyFaucet {
    mapping (address => bool) public donor; 

    event Sent(address recipient);

    // Anybudy can donete to this contract.    
    function donate() external payable {
        require(msg.value > 0.05 ether, "ETH is require an least 0.05 ether.");
        donor[msg.sender] = true;
    }

    // Ask for some eth.
    function sendTo(address payable recipient) 
        external 
    {
        require(recipient != address(0), "Invalid address");

        (bool sent, ) = recipient.call{value: 0.05 ether}("");
        require(sent, "Failed to send ETH");

        emit Sent(recipient);
    }

    // Allow contract to recive ETH 
    receive() external payable { }
}