// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract PollStation {
    //candidate details -> Array -> uint []
    uint[4] public candidates; // [0, 1, 2, 3]
    address public owner;
    uint public timeLimit;
    
    bool pollActive = false;
    uint timeStart;
    uint timeEnd;

    mapping (address => uint) private votesForCandidates; //remamber how voted for which candidate mapping address => uint
    mapping  (address => bool) public alreadyVoted; // Poeple already voted 
    
    constructor() {
        owner = msg.sender;
    }

    event PollStart(bool indexed pollActive);
    event PollFinish(bool indexed pollActive);

    function votar(uint candiate) public {
        require(pollActive);
        require(candiate < candidates.length, "Invalid candidate");
        require(!alreadyVoted[msg.sender], "You have alredy voted");

        candidates[candiate]++;
        votesForCandidates[msg.sender] = candiate;
        alreadyVoted[msg.sender] = true;
    }

    function startPolling(uint timeSeconds) public onlyowner {
        require(!pollActive, "Poll is already started ");

        timeLimit = block.timestamp + timeSeconds;
        pollActive = true;
    
        emit PollStart(pollActive);
    }
    
    function finishPoll () public onlyowner {
        require(pollActive, "Poll is not started yet ");
        pollActive = false;
        
        emit PollFinish(pollActive);
    }

    modifier onlyowner() {
        require(msg.sender == owner, "Only the owner can call this method"); 
        _;
    }
}