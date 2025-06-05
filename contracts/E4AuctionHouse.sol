// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract AuctionHouse {

    mapping (address => uint) public balanceOf;
    address public betterBidAddress;
    uint public betterBidAmount;

    uint public timeEnd = 0;
    address public immutable owner;

    function bid(uint amount) external onlyOpenAuction{
        require(amount > 0, "Amount must be greater than 0");
        require(amount > betterBidAmount, "Bid must be higher than current bidder");
        balanceOf[msg.sender] = amount;
        betterBidAddress = msg.sender;
        betterBidAmount = amount;
    }

    function startAuction(uint timeInSeconds) public onlyOwner{        
        require(timeEnd < block.timestamp, "Aution already started");
        timeEnd = block.timestamp + timeInSeconds ;
    }

    function endAuction() public onlyOwner onlyOpenAuction {
        timeEnd = 0;
    }

    // Helpers 
    function getWinner() public view onlyFinishedAuction returns (address, uint) {
    return (betterBidAddress, betterBidAmount);
    }   

    modifier onlyOwner() { require(msg.sender == owner, "Not owner"); _; }
    modifier onlyOpenAuction(){require (timeEnd > block.timestamp, "Aution is not Open"); _;}
    modifier onlyFinishedAuction(){require (timeEnd < block.timestamp, "Aution still Open"); _;}
    
}