// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "./Models.sol";

library Rules {

	function _isWinner(Models.Tile tile) internal pure returns (bool) {
		uint8(tile) > 0 ? true : false; // tile !== empty
	}

	// For testing
	function checkForWinner (Models.Tile[] storage board, uint8 length) external view returns (Models.Tile) {
		return _checkForWinner(board, length);
	}

	/*
	 * @notice Check the game board for rows, columns, or diagonals that are all Os or all Xs
	 * @dev If draw or still playing returns Tile.Empty
	 * @returns false for player1, true for player2, 
	 */
	function _checkForWinner (Models.Tile[] storage board, uint8 length) internal view returns (Models.Tile result) {
		// @TODO this check only needs to return a bool, as the winner will be whoever is taking the current turn
		result = _checkRows(board, length);
		if(_isWinner(result)) return result;
		result = _checkColumns(board, length);
		if(_isWinner(result)) return result;
		result = _checkDiagonals(board, length);
		return result;
	}

	function _checkRows (Models.Tile[] storage board, uint8 length) internal view returns (Models.Tile winner) {
		// implement as in game-logic.js
	}

	function _checkColumns (Models.Tile[] storage board, uint8 length) internal view returns (Models.Tile winner) {
		// implement as in game-logic.js
	}

	function _checkDiagonals (Models.Tile[] storage board, uint8 length) internal view returns (Models.Tile winner) {
		// implement as in game-logic.js
	}
}
