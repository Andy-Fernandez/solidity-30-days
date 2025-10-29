// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

/*
    - Anyone can donate to the contract (at least 0.05 ETH)
    - Donors are stored in a mapping
    - Anyone can send ETH to any address (via claim)
    - Cooldown: 24 hours
    - Use constants for COOLDOWN, CLAIM_AMOUNT and MIN_DONATION
    - Add ownership
    - Ownership can pause the faucet

    TODO:
    - Add modifiers
    - Use pausable in all the functions to stop claimings.
        - Take a look if its apply in each necesary place
*/

contract MyFaucet {
    mapping(address => bool) public donor;
    mapping(address => uint256) public cooldown;
    address owner;
    bool public paused;

    uint32  public constant COOLDOWN      = 1 days;
    uint256 public constant CLAIM_AMOUNT  = 0.05 ether;
    uint256 public constant MIN_DONATION  = 0.05 ether;

    event Donated(address indexed donor, uint256 amount);
    event Claimed(address indexed recipient, uint256 amount);

    // === modifieres ====
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier isPause() {
        require(paused, "Contract is pause");
        _;
    }

    constructor() {
        owner = msg.sender;

    }

    // Anybody can donate to this contract.
    function donate() external payable {
        require(msg.value >= MIN_DONATION, "Minimum donation is 0.05 ETH");
        donor[msg.sender] = true;
        emit Donated(msg.sender, msg.value);
    }

    // Ask for some ETH.
    function claim(address payable recipient) external isPause {
        require(address(this).balance >= CLAIM_AMOUNT, "Not enough ETH in contract");
        require(recipient != address(0), "Invalid address");
        require(block.timestamp >= cooldown[recipient] + COOLDOWN, "Address is on cooldown");

        // 1) Update state first
        cooldown[recipient] = block.timestamp;

        // 2) External interaction
        (bool sent, ) = recipient.call{value: CLAIM_AMOUNT}("");
        require(sent, "Failed to send ETH");

        // 3) Emit event
        emit Claimed(recipient, CLAIM_AMOUNT);
    }

    // Check if msg.sender can claim now.
    function canClaim() external view returns (bool)  {
        return block.timestamp >= cooldown[msg.sender] + COOLDOWN;
    }

    // Pause the faucet 
    function switchFaucetState() 
        external 
        onlyOwner
        {
            paused = !paused;
    }



    // Allow contract to receive ETH (enforce minimum and mark donor).
    receive() external payable {
        require(msg.value >= MIN_DONATION, "Minimum donation is 0.05 ETH");
        donor[msg.sender] = true;
        emit Donated(msg.sender, msg.value);
    }
}
