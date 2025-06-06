// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract AdminOnly {
    
    // uint treasure = 0; // No es necesaria esta linea por que el contrato mismo es el que guarda todas las transacciones
    address owner;

    mapping (address => bool) whitelist;

    constructor (){
        owner = msg.sender;
    }

    function deposit(uint amount) external  {
        payable(msg.sender).transfer(amount);
    }

    function whitdraw(uint amount) public  onlyOwner {
        require (treasure < amount, "Insufficient funds!");


        payable(msg.sender).transfer(amount);
        
        treasure += amount;
        return true;
    }


    /* --------------- */
    /* MODIFIERS       */
    /* --------------- */ 

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier onlyWhitelist(){
        require(whitelist[msg.sender], "Not whitelisted...");
        _; 
    }
}