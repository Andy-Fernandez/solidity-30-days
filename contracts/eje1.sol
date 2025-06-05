// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract practica {
    string storredInfo = "practica";
    function SetInfo (string memory newString) public { 
        storredInfo = newString;
    }
    
    function getInfo () public view returns (string memory){ 
        return storredInfo;
    }
}