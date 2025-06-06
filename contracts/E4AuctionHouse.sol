// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract AuctionHouse {
    address public immutable owner;
    address public betterBidAddress;
    uint public betterBidAmount;
    uint public timeEnd;

    mapping(address => uint) public pendingReturns;

    event NewHighestBid(address indexed bidder, uint amount);
    event AuctionStarted(uint endTime);
    event AuctionEnded(address winner, uint amount);

    constructor() {
        owner = msg.sender;
    }

    function startAuction(uint timeInSeconds) public onlyOwner {
        require(timeEnd < block.timestamp, "Auction already active");
        timeEnd = block.timestamp + timeInSeconds;
        emit AuctionStarted(timeEnd);
    }

    function bid() external payable onlyOpenAuction {
        require(msg.value > betterBidAmount, "Must outbid current highest");

        if (betterBidAmount > 0) {
            pendingReturns[betterBidAddress] += betterBidAmount;
        }

        betterBidAddress = msg.sender;
        betterBidAmount = msg.value;

        emit NewHighestBid(msg.sender, msg.value);
    }

    function withdraw() external {
        uint amount = pendingReturns[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        pendingReturns[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function endAuction() public onlyOwner onlyOpenAuction {
        timeEnd = 0;
        emit AuctionEnded(betterBidAddress, betterBidAmount);
    }

    function getWinner() public view onlyFinishedAuction returns (address, uint) {
        return (betterBidAddress, betterBidAmount);
    }

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyOpenAuction() {
        require(timeEnd > block.timestamp, "Auction not active");
        _;
    }

    modifier onlyFinishedAuction() {
        require(timeEnd > 0 && timeEnd < block.timestamp, "Auction not finished");
        _;
    }

    // Accept ETH
    receive() external payable {}
}
