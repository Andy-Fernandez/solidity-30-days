// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RPSBet is ReentrancyGuard {
    enum Move { None, Rock, Paper, Scissors }
    enum Stage { Created, Joined, Reveal, Finished }

    uint256[3] public BET_SIZES = [0.01 ether, 0.05 ether, 0.1 ether];

    struct Game {
        address payable p1;
        address payable p2;
        uint256 bet;
        Stage stage;
        uint8 round;              // 0,1,2  (best of 3)
        mapping(address => bytes32[3]) commits;
        mapping(address => Move[3]) moves;
        uint8 p1Wins;
        uint8 p2Wins;
        uint256 lastAction;       // timestamp for timeout
    }

    uint256 public constant JOIN_WINDOW = 30 minutes;
    uint256 public constant REVEAL_WINDOW = 30 minutes;

    uint256 public nextGameId = 1;
    mapping(uint256 => Game) private games;

    event GameCreated(uint256 indexed id, address indexed creator, address indexed opponent, uint256 bet);
    event GameJoined(uint256 indexed id, address indexed joiner);
    event MoveCommitted(uint256 indexed id, address indexed player, uint8 round);
    event MoveRevealed(uint256 indexed id, address indexed player, uint8 round, Move move);
    event GameFinished(uint256 indexed id, address winner, uint256 prize);

    /* **************************************
            GAME FLOW FUNCTIONS
    *****************************************/

    // Crea una nueva partida
    function createGame(
        address payable _opponent,
        uint8 betIndex,
        bytes32[3] calldata _commitments
    ) external payable nonReentrant returns (uint256 gameId) {
        require(betIndex < 3, "betIndex invalid");
        uint256 wager = BET_SIZES[betIndex];
        require(msg.value == wager, "incorrect ETH sent");

        gameId = nextGameId++;
        Game storage g = games[gameId];
        g.p1 = payable(msg.sender);
        g.p2 = _opponent;
        g.bet = wager;
        g.stage = Stage.Created;
        g.lastAction = block.timestamp;

        g.commits[msg.sender] = _commitments;

        emit GameCreated(gameId, msg.sender, _opponent, wager);
    }

    // El segundo jugador entra a la partida
    function joinGame(uint256 id, bytes32[3] calldata _commitments) external payable nonReentrant {
        Game storage g = games[id];
        require(g.stage == Stage.Created, "not joinable");
        require(msg.sender == g.p2, "not invited");
        require(msg.value == g.bet, "incorrect ETH sent");
        require(block.timestamp <= g.lastAction + JOIN_WINDOW, "join timeout");

        g.commits[msg.sender] = _commitments;
        g.stage = Stage.Joined;
        g.lastAction = block.timestamp;

        emit GameJoined(id, msg.sender);
    }

    // Revela jugada para la ronda actual
    function reveal(
        uint256 id,
        uint8 round,
        Move _move,
        string calldata _salt
    ) external nonReentrant {
        Game storage g = games[id];
        require(g.stage == Stage.Joined || g.stage == Stage.Reveal, "bad stage");
        require(round == g.round, "wrong round");
        require(_move >= Move.Rock && _move <= Move.Scissors, "bad move");

        // Verifica que el hash coincida
        bytes32 hashCheck = keccak256(abi.encodePacked(_move, _salt));
        require(hashCheck == g.commits[msg.sender][round], "commit mismatch");

        g.moves[msg.sender][round] = _move;
        emit MoveRevealed(id, msg.sender, round, _move);

        // Si ambos jugadores revelaron, evalúa la ronda
        address other = msg.sender == g.p1 ? g.p2 : g.p1;
        if (g.moves[other][round] != Move.None) {
            _scoreRound(g, round);
        } else {
            g.stage = Stage.Reveal;
            g.lastAction = block.timestamp;
        }
    }

    // Reclama la victoria si el oponente no aparece o no revela
    function claimTimeout(uint256 id) external nonReentrant {
        Game storage g = games[id];
        require(g.stage != Stage.Finished, "game over");
        bool timeout = (g.stage == Stage.Created && block.timestamp > g.lastAction + JOIN_WINDOW) ||
                       (g.stage == Stage.Reveal && block.timestamp > g.lastAction + REVEAL_WINDOW);
        require(timeout, "no timeout yet");

        address payable winner;
        if (g.stage == Stage.Created) {
            winner = g.p1;  // Oponente nunca se unió
        } else {
            if (g.moves[g.p1][g.round] != Move.None) winner = g.p1;
            else winner = g.p2;
        }
        _payout(g, winner);
    }

    /* **************************************
                INTERNAL HELPERS
    *****************************************/

    // Calcula los resultados de la ronda
    function _scoreRound(Game storage g, uint8 round) private {
        Move m1 = g.moves[g.p1][round];
        Move m2 = g.moves[g.p2][round];

        if (m1 == m2) {
            // empate, no puntuar
        } else if ((uint8(m1) + 1) % 3 == uint8(m2)) {
            // P2 gana
            g.p2Wins++;
        } else {
            // P1 gana
            g.p1Wins++;
        }

        g.round++;

        // Verifica condiciones de fin de juego
        if (g.p1Wins == 2 || g.p2Wins == 2 || g.round == 3) {
            address payable winner;
            if (g.p1Wins > g.p2Wins) winner = g.p1;
            else if (g.p2Wins > g.p1Wins) winner = g.p2;
            else winner = payable(address(0)); // empate

            _payout(g, winner);
        } else {
            // Continuar con la siguiente ronda
            g.stage = Stage.Joined;
            g.lastAction = block.timestamp;
        }
    }

    // Transfiere el premio al ganador
    function _payout(Game storage g, address payable winner) private {
        g.stage = Stage.Finished;

        uint256 pot = g.bet * 2;
        if (winner == address(0)) {
            // empate
            g.p1.transfer(g.bet);
            g.p2.transfer(g.bet);
            emit GameFinished(0, address(0), 0);
        } else {
            (bool ok, ) = winner.call{value: pot}("");
            require(ok, "transfer failed");
            emit GameFinished(0, winner, pot);
        }
    }

    /* **************************************
                FALLBACKS
    *****************************************/

    receive() external payable {
        revert("Send ETH via createGame/joinGame");
    }
}
