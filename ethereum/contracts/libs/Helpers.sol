// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

library Helpers {
	// For testing purposes
	function getInitiative(address player1, address player2) external pure returns (bool initiative) {
		return _getInitiative(player1, player2);
	}

	/*
	 * @notice Decide who gets the first turn
	 * @returns false for player1, true for player2
	 */
	function _getInitiative(address player1, address player2) internal pure returns (bool initiative) {
		bytes32 hash = keccak256(abi.encodePacked(player1, player2));

		// Big endian
		uint8 firstBit = _getFirstBit(uint8(hash[0]));
		initiative = !(firstBit > 0);
	}

	// For testing purposes
	function getFirstBit(uint8 val) external pure returns (uint8) {
		return _getFirstBit(val);
	}

	function _getFirstBit(uint8 val) internal pure returns (uint8) {
		return (val & (1 << 7));
	}

}
