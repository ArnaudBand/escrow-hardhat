// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract Escrow {
	address public arbiter;
	address public beneficiary;
	address public depositor;
	uint public amount;

	enum State { AWAITING_DEPOSITOR, AWAITING_ARBITER, COMPLETE }

	State public state;
}
