// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

2 Vault {

    struct User {
        uint256 id;
        address wallate;
        uint64 lastDesposit;
        bool isActive;
    }
    mapping (address => User) private users;

    function updateUser(User memory _newUser ) external  {
        users[msg.sender] = _newUser;
    }
}

contract VaultOptimized {

    struct User {
        // No necessitamos la id ni la wallet porque ya se esta usando eso en mapping
        uint64 lastDesposit;
        bool isActive; // el tema de isActive tal vez es depende a para que lo usaremos pero si esta en el mapping y devuelve algo entonces tal vez no es necesario, me imagino que devuelve true en las estrcucturas 
    }
    mapping (address => User) private users;

    function updateUser(User memory _newUser ) external  {
        users[msg.sender] = _newUser;
    }
}