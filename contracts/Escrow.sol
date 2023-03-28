// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Escrow {
	address public arbiter;
	address public beneficiary;
	address public depositor;
	uint public amount;

	enum State { AWAITING_DEPOSIT, AWAITING_ARBITER, COMPLETE }

	State public state;

	modifier onlyArbiter() {
		require(msg.sender == arbiter, "Only arbiter can perform this action.");
		_;
	}

	modifier inState(State _state) {
		require(state == _state, "Invalid State");
		_;
	}

	constructor(address _arbiter, address _beneficiary) {
		arbiter = _arbiter;
		beneficiary = _beneficiary;
		state = State.AWAITING_DEPOSIT;
	}

	function deposit() public payable inState(State.AWAITING_DEPOSIT) {
		require(msg.sender == depositor, "Only depositor can perfom this action.");
		amount = msg.value;
		state = State.AWAITING_ARBITER;
	}
}
