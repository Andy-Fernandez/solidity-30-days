// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract SimpleIOU {
    address public owner;
    
    // Track balances of ETH for each user
    mapping(address => uint256) public balances;
    
    // Simple debt tracking: debtor -> creditor -> amount
    mapping(address => mapping(address => uint256)) public debts; 

    // Events to log activities
    event Deposit(address indexed user, uint256 amount);
    event DebtRecorded(address indexed debtor, address indexed creditor, uint256 amount);
    event DebtPaid(address indexed debtor, address indexed creditor, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    // Constructor to set the owner of the contract
    constructor() {
        owner = msg.sender; // The person who deploys the contract is the owner
    }

    // Modifier to ensure only the contract owner can call certain functions
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    // Modifier to ensure only registered users (friends) can interact
    modifier onlyRegistered() {
        require(balances[msg.sender] > 0, "You need to have a balance to interact");
        _;
    }

    // Deposit ETH into the contract (payable function)
    function deposit() external payable {
        require(msg.value > 0, "Must send ETH to deposit");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Record that someone owes you money (a simple debt recording)
    function recordDebt(address _debtor, uint256 _amount) external onlyRegistered {
        require(_debtor != address(0), "Invalid address");
        require(_debtor != msg.sender, "You cannot owe yourself");
        require(balances[_debtor] >= _amount, "Debtor does not have enough balance");

        // Increase the debt for the debtor
        debts[_debtor][msg.sender] += _amount;
        emit DebtRecorded(_debtor, msg.sender, _amount);
    }

    // Pay off a debt from one user to another
    function payDebt(address _creditor, uint256 _amount) external onlyRegistered {
        require(debts[msg.sender][_creditor] >= _amount, "Not enough debt to pay");
        require(balances[msg.sender] >= _amount, "Insufficient balance to pay debt");

        // Decrease the balance of the debtor
        balances[msg.sender] -= _amount;
        // Increase the balance of the creditor
        balances[_creditor] += _amount;

        // Decrease the debt from the debtor to the creditor
        debts[msg.sender][_creditor] -= _amount;

        // Emit an event
        emit DebtPaid(msg.sender, _creditor, _amount);
    }

    // Withdraw ETH from the contract (payable function)
    function withdraw(uint256 _amount) external onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        // Decrease the balance
        balances[msg.sender] -= _amount;

        // Transfer the ETH to the user
        payable(msg.sender).transfer(_amount);

        // Emit an event
        emit Withdrawal(msg.sender, _amount);
    }

    // Check the balance of a user
    function checkBalance() external view returns (uint256) {
        return balances[msg.sender];
    }
}
