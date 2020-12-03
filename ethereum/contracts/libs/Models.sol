// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

library Models {
	enum Tile { Empty, Cross, Naught }
	enum Stages { New, Playing, Complete }

	// Giving readability precedence over gas cost unless the gas cost is very significant at scale (e.g. transaction costs or storage costs);
	// A bool is stored as a whole byte so no impact here using an enum
	// @TODO could implement all the turns in the contract as a bitmask to save gas
	enum Turn { Player1, Player2 }

	// Game board is always square
	struct Game {
		// uint8 length; // static board size for now
		Tile[] board; // using 1D array as it makes the interface to the contract much simpler
		address player1;
		address player2;
		// uint wager; // gambling
		Stages stage;
		Turn turn; // false: player 1, true, player 2;
		uint8 turns; // keep track of turns to easily check for draws
	}
}
