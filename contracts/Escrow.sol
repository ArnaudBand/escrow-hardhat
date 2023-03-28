// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Escrow {
	address public arbiter;
	address public beneficiary;
	address public depositor;
	uint public amount;

	enum State { AWAITING_DEPOSITOR, AWAITING_ARBITER, COMPLETE }

	State public state;

	modifier onlyArbiter() {
		require(msg.sender == arbiter, "Only arbiter can perform this action.");
		_;
	}

	modifier inState(State _state) {
		require(state == _state, "Invalid State");
		_;
	}
}
