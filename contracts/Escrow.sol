// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Escrow {
    address public arbiter;
    address public beneficiary;
    address public depositor;

    bool public isApproved;

    constructor(address _arbiter, address _beneficiary) payable {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
    }

    event Approved(uint);
    event DisputeStarted();

    function approve() external {
        require(msg.sender == arbiter);
        uint balance = address(this).balance;
        (bool sent, ) = payable(beneficiary).call{value: balance}("");
        require(sent, "Failed to send Ether");
        emit Approved(balance);
        isApproved = true;
    }

    function cancel() external {
        require(msg.sender == arbiter && !isApproved);
        uint balance = address(this).balance;
        (bool sent, ) = payable(depositor).call{value: balance}("");
        require(sent, "Failed to send Ether");
    }

    function startDispute() external {
        require(msg.sender == arbiter || msg.sender == beneficiary, "Invalid caller");
        require(!isApproved, "Transaction already approved");
        emit DisputeStarted();
    }

    function releaseToBeneficiary() external {
        require(msg.sender == arbiter, "Invalid caller");
        require(isApproved, "Transaction not approved");
        uint balance = address(this).balance;
        (bool sent, ) = payable(beneficiary).call{value: balance}('');
        require(sent, "Failed to send ether");
    }
}
