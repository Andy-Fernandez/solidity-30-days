// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract AdminOnly {
    address public owner;

    mapping(address => bool) public whitelist;
    mapping(address => bool) public hasWithdrawn;
    mapping(address => uint) public withdrawalPermit;

    event TreasureDeposited(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);

    constructor() {
        owner = msg.sender;
    }

    // Receive ETH
    receive() external payable {
        emit TreasureDeposited(msg.sender, msg.value);
    }

    function deposit() external payable {
        emit TreasureDeposited(msg.sender, msg.value);
    }

    function withdraw(uint amount) public onlyOwner onlyWhitelist notWithdrawn {
        require(address(this).balance >= amount, "Insufficient funds!");
        require(amount <= withdrawalPermit[msg.sender], "Not approved to withdraw this amount");

        hasWithdrawn[msg.sender] = true;
        withdrawalPermit[msg.sender] = 0; // Optional: reset
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function ownerWithdraw(uint amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient funds!");
        payable(msg.sender).transfer(amount);
    }

    function addWhitelist(address user) public onlyOwner {
        whitelist[user] = true;
    }

    function setWithdrawalPermit(address user, uint amount) public onlyOwner {
        withdrawalPermit[user] = amount;
    }

    function resetWithdrawal(address user) public onlyOwner {
        hasWithdrawn[user] = false;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid address");
        owner = newOwner;
    }

    function getTreasureBalance() external view returns (uint) {
        return address(this).balance;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier onlyWhitelist() {
        require(whitelist[msg.sender], "Not whitelisted...");
        _;
    }

    modifier notWithdrawn() {
        require(!hasWithdrawn[msg.sender], "You already withdrew.");
        _;
    }
}
