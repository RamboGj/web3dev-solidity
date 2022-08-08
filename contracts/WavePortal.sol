// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    // struct é semelhante ao type ou interface no typescript
    // me permite determinar o que quero armazenar em uma var
    struct Wave {
        address waver; //endereço de quem acenou
        string message; // a mensagem que foi enviada pelo waver
        uint256 timestamp; // data/hora do envio do wave   
    }

    // Aqui estou declaranado a variável de armazenamento
    // do tipo Wave[]
    Wave[] waves;

    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("Agora posso pagar pessoas!");

        //definir seed inicial
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        require(
            lastWavedAt[msg.sender] + 15 minutes < block.timestamp,
            "Espere 15m"
        );
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s deu tchauzinho com a mensagem %s", msg.sender);

        // Armazenando o tchauzinho de fato passando os params
        waves.push(Wave(msg.sender, _message, block.timestamp));
    
        // Gera uma nova seed para o próximo que mandar tchauzinho
        seed = (block.difficulty + block.timestamp + seed) % 100;
        console.log("# randomico gerado: %d", seed);

        // Dá 50% de chance do usuario ganhar o prêmio.
        if (seed <= 50) {
            console.log("%s ganhou!", msg.sender);
        }

        emit NewWave(msg.sender, block.timestamp, _message);

        uint256 prizeAmount = 0.0001 ether;

        // require é semelhante ao if
        
        // if(condição) {resposta}
        // require(condição, resposta)
        // se a condição for true, sairá do require e continuará o contrato
        
        // se a condição for false, continuará com a resposta do requrie
        // e matará a transação
        require(
            prizeAmount <= address(this).balance, //address(this) é o próprio contrato
            "Tentando sacar mais dinheiro que o contrato possui."
        );
        //(msg.sen)... é a função que envia valor monetário
        (bool success, ) = (msg.sender).call{value: prizeAmount}("");
        require(success, "Falhou em sacar dinheiro do contrato.");
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("Temos um total de %d tchauzinhos!", totalWaves);
        return totalWaves;
    }
}