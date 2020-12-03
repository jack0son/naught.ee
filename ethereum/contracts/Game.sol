// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./libs/Models.sol";
import "./libs/Rules.sol";
import "./libs/Helpers.sol";

// Problems faced
// -----------------------
//	- ran out of time to test the contract so I'm aware of many places where there could be out by one errors or where the game state is resolved incorrectly
//	- on mainnet I would make the client to do a lot more 'work'
//		- i.e. passing moves as an array index, not a grid position
//  - could have made storing the roles more implicit (i.e. cheaper)
//  - wrote some ugly code to get what I had compiling in the time limit

// @NB Allowing a different board size per game changes the game data model and
// win checking algorithm therefore I chose to keep to a static 3x3 board to get
// the transaction flow in place first

// @NB Multidimensional dynamic array return values are not supported by ABI coder v1
// e.g.
// function return2DDynamicArry() public returns (uint[][] memory nested) { ... }
// Makes implementing larger boards and the external calls to get the game board simpler

// @NB roles are implicit in the current turn: use current turn and number of
// turns to calculate who is O and who is X

/*
 * @notice Main Contract
 * @dev Some dev info
 */
contract Game {
	uint gameCounter;
	mapping(uint => Models.Game) gamesById;

	// @dev First dev pass the board length will be kept static;
	uint8 boardLength = 3;
	uint8 maxBoardLength;
	// uint8 streakToWin; // number of tiles in a row to win

	constructor() {
	  // require(streakToWin <= boardLength); // number of tiles in a row to win
	}

	// function createGame(uint8 _boardLength, address _player2) external payable {
	function invite(address _player2) external
	{
		address player1 = msg.sender;
		require(player1 != _player2, 'Player cannot invite themself');

		// Wager is an amount to bet on the game
		//	Minimum: none. Gambling is not mandatory.
		//	Maximum: none. No protection. Your tx your choice.
		// uint wager = msg.value;
		// Check wager size

		// @TODO variable board length

		uint gameId = gameCounter++;
		Models.Tile[] memory board = new Models.Tile[] (boardLength);
		gamesById[gameId] = Models.Game({
			board: board,
			player1: player1,
			player2: _player2,
			stage: Models.Stages.New,
			turn: Models.Turn(0), // initialised in accept()
			turns: 0
		});

		emit NewGame(gameId, gameId, player1, _player2, player1, _player2);
	}

	function accept(uint8 _gameId) external payable
		gameExists(_gameId)
		onlyPlayer2(_gameId)
		gameIsNew(_gameId)
		//wagerIsMet(_gameId) // confirm funds in and out of the contract are correct
	{
		Models.Game storage game = gamesById[_gameId];
		// uint wager = msg.value;
		// require(wager == game.wager, 'Player 2 must meet the buy in wager');

		game.stage = Models.Stages.Playing;
		game.turn = Helpers._getInitiative(game.player1, game.player2) ? Models.Turn.Player2 : Models.Turn.Player1;

		// @TODO return excess funds
		// uint refund = wager - game.wager;
		// game.player2.transfer(refund);
	}

	/*
	 * @notice Play a turn
	 * @dev Translating a grid position could be done in the contract or the client (cheaper in the client of course)
	 * @param _row row position of move
	 * @param _col column posiiton of move
	 * @returns false for player1, true for player2
	 */
	function play(uint _gameId, uint8 _row, uint8 _col) external
		gameIsActive(_gameId)
	{
		Models.Game storage game = gamesById[_gameId];
		// Use a require not a modifier as we only want to set the game reference once
		require(_isMyTurn(game), 'Not your turn');

		uint8 idx = (_row * boardLength) + _col;
		require(idx < boardLength ** 2, 'Not a valid board position'); // check position is valid

		Models.Tile tile = game.board[idx];

		// Check tile is empty
		require(tile == Models.Tile.Empty, 'Chosen tile must be empty.');

		Models.Tile role = game.turns % 2 == 0 ? Models.Tile.Cross : Models.Tile.Naught;

		// Take the turn
		tile = role;
		game.turns++;

		// Evaluate new game state
		Models.Tile gameState = _checkForWinner(game);
		if(gameState == Models.Tile.Empty) {
			// No winner
			if(game.turns == boardLength ** 2) {
				// Draw
				game.stage = Models.Stages.Complete;

				// @TODO refund both player's wagers
				emit Complete(_gameId, _gameId, address(0), address(0));
				return; // transfers are the last state mutation!
			} else {
				// Keep playing
				game.turn = (game.turn == Models.Turn.Player1) ? Models.Turn.Player2 : Models.Turn.Player2;

				// game.turn = Models.Turn(!bool(game.turn)); // toggle the game turn
			}
		} else {
			address winner = msg.sender;
			game.stage = Models.Stages.Complete;
			emit Complete(_gameId, _gameId, winner, winner);
			// @TODO transfer the wagered ETH to the winner
			return; // transfers are the last state mutation!
		}
	}

	/*
	 * @notice Check the current board state for a winner
	 * @dev Turn.Empty is alias for draw or keep playing
	 * @dev call external helper so the game state rules can be more easily tested in isolation
	 * @param _game storage ref to game struct
	 * @returns false for player1, true for player2
	 */
	function _checkForWinner(Models.Game storage _game) internal view returns (Models.Tile) {
		// Possible states: [X win, O win, draw, still_playing]
		return Rules._checkForWinner(_game.board, boardLength);
	}

	// ------- View API
	function getTurn(uint _gameId) external view returns (address) {
		address player = uint8(gamesById[_gameId].turn) == 0 ? gamesById[_gameId].player1 : gamesById[_gameId].player2;
	}

	function isMyTurn(uint8 _gameId) external view returns (bool) {
		return _isMyTurn(gamesById[_gameId]);
	}

	// ------- Internal helpers
	function _isPlayer1(uint _gameId) internal view returns (bool) {
		return (msg.sender == gamesById[_gameId].player1);
	}
	function _isPlayer2(uint _gameId) internal view returns (bool) {
		return (msg.sender == gamesById[_gameId].player2);
	}

	function _gameStageIs(uint _gameId, Models.Stages _stage) internal view returns (bool) {
		return (gamesById[_gameId].stage == _stage);
	}

	function _gameExists(uint _gameId) internal view returns (bool) {
		return _gameId <= gameCounter;
	}

	function _isMyTurn(Models.Game storage game) internal view returns (bool) {
		if(msg.sender == game.player1) return game.turn == Models.Turn.Player1;
		if(msg.sender == game.player2) return game.turn == Models.Turn.Player2;
	}

	// ------- Modifiers
	// Call to internal functions results in significant gas saving when modifier is used more than once
	modifier onlyPlayer2(uint _gameId) {
		require(_isPlayer2(_gameId));
		_;
	}

	// modifier wagerIsMet(uint gameId) {
	// 	// @TODO check contract balance increases by the wager amount
	// 	_;
	// }

	modifier gameExists(uint _gameId) {
		require(_isPlayer2(_gameId));
		_;
	}

	modifier gameIsActive(uint _gameId) {
		require(_gameStageIs(_gameId, Models.Stages.Playing));
		_;
	}

	modifier gameIsNew(uint _gameId) {
		require(_gameStageIs(_gameId, Models.Stages.New));
		_;
	}

	modifier gameIsComplete(uint _gameId) {
		require(_gameStageIs(_gameId, Models.Stages.Complete));
		_;
	}

	modifier gameInProgress(uint _gameId) {
		require(_isPlayer2(_gameId));
		_;
	}

	// Indexed event params make client implementation a bit easier, but you are technically paying for gas instead of client CPU cycles to build an index (i.e. free!)
	event NewGame(uint indexed idx_gameId, uint gameId, address indexed idx_player1, address indexed idx_player2, address player1, address player2); // , uint wager);
	event Accepted(uint indexed idx_gameId, uint gameId, bool firstTurn);

	// Draw represented by winner == address(0)
	event Complete(uint indexed idx_gameId, uint gameId, address indexed idx_winner, address winner);
}
