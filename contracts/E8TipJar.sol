// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

contract TipJar {
    address public owner; 

    mapping (address => mapping (string => uint)) tips; // how -> currency -> amount
    
    event tipRecive(address from, string currency, uint amout);
    
    // Las personas van a ir depositando en ETH
    
    // ¿Que hacemos si las personas depositan en otra mondea?
    // Tenemos que saber que moneda es
    // El 'owner' puede determinar que tipos de moneda se aceptan. para comenzar tenemos ETH, USD y EUR. 
    
    // Tenemos que ver el tema del tipo de cambio. Si es que se deposita en USD entonces lo convertimos a dolares?
    // Se tendría que poder ver cuanto USD, ETH, EUR se tiene. 
}
