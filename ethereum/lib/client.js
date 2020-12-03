// @TODO implement client side functions

const tiles = { empty: 0, x: 1, o: 2 };

function whoIsNaughts() {}

function turnsPlayed(board) {
	let counts = { empty: 0, x: 0, o: 0 };

	board.forEach((tile) => {
		if (tile === undefined || tile === null) throw new Error('Board contains empty tiles');
		if (tile[tiles] === undefined || tile[tiles] === null) throw new Error('Board contains invalid tile');

		counts[tile]++;
	});
}
