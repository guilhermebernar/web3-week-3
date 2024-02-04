// SPDX-License-Identifier: MIT
// A linha SPDX-License-Identifier é usada para declarar a licença do código fonte. Neste caso, é a Licença MIT.

pragma solidity ^0.8.21;
// 'pragma' especifica a versão do compilador Solidity que deve ser usada. 
// Isso ajuda a garantir que o contrato funcione conforme esperado em versões específicas do compilador.

// Estrutura para representar uma votação. 
// Estruturas são tipos de dados personalizados que permitem a definição de vários atributos.
struct Voting {
    string option1;  // Representa a primeira opção de voto. 'string' é usado para texto.
    uint256 votes1;  // Contagem de votos para a opção 1. 'uint256' é um tipo de dado para números inteiros não negativos.
    string option2;  
    uint256 votes2;  
    uint256 maxDate; // Data limite para votar. 'uint256' pode representar datas como timestamps UNIX.
}

struct Vote {
    uint256 choice; // Armazena a escolha do voto. Deve ser 1 ou 2.
    uint256 date;   // Armazena a data do voto como um timestamp UNIX.
}

// Contrato principal
contract Webbb3 {
    address owner; // Endereço do proprietário. 'address' é um tipo de dado para endereços Ethereum.
    uint256 public currentVoting; // Índice público da votação atual. 'public' faz com que o Solidity crie automaticamente um getter.
    Voting[] public votings; // Array dinâmico para armazenar votações.
    // Mapeamento de índice de votação para (mapeamento de eleitor para Voto).
    // É um exemplo de mapeamento aninhado.
    mapping(uint256 => mapping(address => Vote)) public votes; 

    // Construtor chamado no momento do deploy do contrato.
    constructor() {
        owner = msg.sender; // 'msg.sender' é o endereço que está criando o contrato, neste caso, o proprietário.
    }

    // Retorna a votação atual. 
    // 'view' significa que a função não modifica o estado do contrato.
    function getCurrentVoting() public view returns (Voting memory) {
        return votings[currentVoting];
    }

    // Adiciona uma nova votação. 
    function addVoting(
        string memory option1,
        string memory option2,
        uint256 timeToVote
    ) public {
        require(msg.sender == owner, "Invalid sender"); // 'require' é usado para verificar condições e reverter a transação se não forem atendidas.
        // 'memory' indica que 'option1' e 'option2' são armazenados temporariamente durante a execução.

        if (votings.length != 0) currentVoting++;
        // Incrementa 'currentVoting' se já existirem votações. Isso move para a próxima votação.

        Voting memory newVoting; // Cria uma nova instância de 'Voting'.
        newVoting.option1 = option1;
        newVoting.option2 = option2;
        newVoting.maxDate = timeToVote + block.timestamp; // 'block.timestamp' fornece o timestamp atual do bloco.
        votings.push(newVoting); // Adiciona 'newVoting' ao array 'votings'.
    }

    // Função para adicionar um voto.
    function addVote(uint256 choice) public {
        require(choice == 1 || choice == 2, "Invalid choice");
        require(getCurrentVoting().maxDate > block.timestamp, "No open voting");
        require(votes[currentVoting][msg.sender].date == 0, "You already voted on this voting");
        // Verifica se o eleitor já votou na votação atual.
        votes[currentVoting][msg.sender].choice = choice;
        votes[currentVoting][msg.sender].date = block.timestamp;
        // Registra o voto do eleitor.
        if (choice == 1) votings[currentVoting].votes1++;
        else votings[currentVoting].votes2++;
        // Atualiza a contagem de votos para a opção escolhida.
    }
}