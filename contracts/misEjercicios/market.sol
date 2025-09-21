// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract decentraliceMarketplace {
    mapping (address => uint) public owners;

    event DepositoRealizado(address indexed _from, uint _value);

    function depositarAlContrato() public payable {
        require(msg.value > 0, "Debes enviar algo de ETH");
        owners[msg.sender] += msg.value;
        emit DepositoRealizado(msg.sender, msg.value);
    }

    /*  Se supone que las personas que envían X cantidad de ETH son
        deuñas en un porcentaje del proyecto y deberíamos poder
        ver en que porcentaje son dueñas.
    */
    function checkMyPorcentOwn() public view returns(uint){
        return address(this).balance / owners[msg.sender];
    }
}

/*
    Tenemos:
        1) Tenemos varios owners.
        2) Cada uno es dueño de un porcenje del proyecto.
        3) El dinero que se recolecta va a tener una ganancia:
            3.1) Con este dinero se pueden hacer diferentes operaciones,
                 el punto es que este dinero genera GANANCIA o PERDIDA.
        4) Las ganancias o perdidas de distribuyen entre los dueños del
           proyecto.
        5) Cada usuario decide si sacar el dinero, reinvertirlo o sacarlo.
            5.1) En caso de ganancia, el dinero no se reinvierte automaticamente,
                 más bien se queda en un estado de retirado pendiente.
            5.2) En caso de perdida, el dinero se descuenta automaticamente.
        Preguntas: ¿Sería ideal crear otro token que represente el valor
                    que tenemos invertido en el contrato?
*/
