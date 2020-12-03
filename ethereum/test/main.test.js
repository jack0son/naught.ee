const chai = require('chai');
chai.use(require('chai-as-promised'));
chai.should();
const { expect, assert } = chai;
const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');

const Helpers = contract.fromArtifact('Helpers');
const Game = contract.fromArtifact('Game');
const [a_owner, a_player1, a_player2, a_referee, a_stranger, ...other_accounts] = accounts;

const zero = new BN(0);
const one = new BN(1);
const two = new BN(2);

describe('Game Contract', function() {
	before(async function() {
		helpers = await Helpers.new({ from: a_owner });
	});

	beforeEach(async function() {
		gameContract = await Game.new(discountPerBlock, { from: a_owner });
	});

	describe('Helpers', function() {
		describe('getInitiative', function() {
			it('if first bit is 0, player1 is naughts', async function() {});

			it('if first bit is 1, player2 is naughts', async function() {});
		});

		describe('getFirstBit', function() {
			it('first bit of 1 is 0', async function() {});
			it('first bit of 255 is 1', async function() {});
			it('', async function() {});
		});
	});
});
