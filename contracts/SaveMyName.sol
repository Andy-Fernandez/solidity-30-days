// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// https://www.web3compass.xyz/challenge-calendar
contract SaveMyName {
    string public name; // ya tenemos por defencto el view
    string public description; // same
    address public owner;

    constructor(string memory _name, string memory _description) {
        name = _name;
        description= _description;
        owner = msg.sender;
    }

    function setName(string memory _newName) external {
        require(msg.sender == owner, "You aren't the owner");
        name = _newName;
    }
}