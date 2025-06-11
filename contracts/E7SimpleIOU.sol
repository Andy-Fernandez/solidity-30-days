// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract SimpleIOU {
    // Aca podemos ver cuanto tiene cada persona en una cuenta, para poder prestar tiene que tener dinero.
    mapping (address => uint) public balance;
    // En esta parte tenemos que el primer address es el dueño del segundo address y le debe una cantidad tal
    mapping (address => mapping (address => uint)) public borrows; 
    mapping (address => mapping (address => uint)) public lent ; 

    // Events
    event BorrowEvent(address borrower, address lender, uint amount);

    // Las personas pueden depositar en sus cuentas
    function deposit() payable external  {
        require(msg.value > 0, "Ether required to pay");
        balance[msg.sender] += msg.value;
    }

    function borrow(address _lender, uint amount) external {
        require(balance[_lender] >= amount, "Insufficient funds");
        balance[_lender] -= amount;  // Debitamos del valor del prestamo
        balance[msg.sender] += amount;   // Creditamos el valor del prestamo
        borrows[_lender][msg.sender] += amount;
        lent [msg.sender][_lender] += amount;
        emit BorrowEvent(msg.sender, _lender, amount);
    }

    function withdrawal(uint _amount) external {
        require(balance[msg.sender] >= _amount, "Insufficient funds");
        require(_amount > 0, "No money required to withdraw "); // No podemos sacar 0
        balance[msg.sender] -= _amount;   // Debitamos del valor del prestamo
        payable(msg.sender).transfer(_amount);
    }
}