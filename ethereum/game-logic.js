// game-logic.js
// Implement smart contract game functions to quickly sketch out correct
// algorithms

const assert = require('assert');

// prettier-ignore
let board_a = [
	'x','o','o',
	'x','o','o',
	'x','o','o',
];

// prettier-ignore
let board_b = [
	'x','o','o',
	'o','x','o',
	'o','o','x',
];

// prettier-ignore
let board_c = [
	'x','o','o',
	'o','x','o',
	'o','o','o',
];

function traverseRows(board, length) {
	for (let i = 0; i < Math.pow(length, 2); i += length) {
		for (let j = i; j < i + length; j++) {
			assert(j === board[j]);
			// console.log(`i:${i}, j${j}, tile: ${board[j]}`);
		}
	}
}

function checkRows(board, length) {
	let win = false;
	let winner = null;
	for (let i = 0; i < Math.pow(length, 2); i += length) {
		let prev = board[i];
		let j;
		for (j = i + 1; j < i + length; j++) {
			if (board[j] !== prev) break;
			// prev = board[j];
		}
		if (j === i + length) {
			win = true;
			winner = prev;
			break;
		}
	}

	return winner;
}

function traverseColumns(board, length) {
	for (let i = 0; i < length; i++) {
		for (let j = 0; j < length; j++) {
			const tileIndex = i + j * length;
			// console.log(`i:${i}, j${j}, idx: ${tileIndex}, tile: ${board[tileIndex]}`);
			assert(tileIndex == board[tileIndex]);
		}
	}
}

function checkColumns(board, length, streakToWin) {
	let winner = null;
	for (let i = 0; i < length; i++) {
		let prev = board[i];
		let j;
		for (let j = 1; j < length; j++) {
			const tileIndex = i + j * length;
			if (board[tileIndex] !== prev) break;
		}

		if (j === length) {
			winner = prev;
			break;
		}
	}

	return winner;
}

// Some versions of tic tac toe allow arb board size and number-in-a-row to
// win
// - not going to use this as it takes the focus off the solidity with the time
// I have available
/*
function checkColumnsArbitraryWinStreak(board, length, streakToWin) {
	let win = false;
	for (let i = 0; i < length; i++) {
		let prev = board[i];
		console.log(prev);
		for (let j = 1; j < length; j++) {
			const tileIndex = i + j * length;
			if (board[tileIndex] !== prev) {
				streak = 0;
				if((length - streak) < streak)  break;
			} else {
				streak++;
				if (streak >= streakToWin) {
					return board[tileIndex];
				}
			}
		}
	}
}
	*/

// Translate cartesian coordinate to board array index
function gridToIndex(row, col, boardLength) {
	return row * boardLength + col;
}

const n = 3;
const board = [...Array(Math.pow(n, 2))].map((v, i) => i);

// Set board contents to
function initTestBoard(board) {
	board = board.map((v, i) => i);
}

// console.log({ board });
initTestBoard(board);
traverseColumns(board, n);
traverseRows(board, n);
checkColumns(board, n);

assert(gridToIndex(0, 0, 3) === 0);
assert(gridToIndex(0, 2, 3) === 2);
assert(gridToIndex(2, 0, 3) === 6);
assert(gridToIndex(1, 1, 3) === 4);
assert(gridToIndex(2, 2, 3) === 8);
