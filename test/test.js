const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('Escrow', function () {
  let contract;
  let depositor;
  let beneficiary;
  let arbiter;
  const deposit = ethers.utils.parseEther('1');
  beforeEach(async () => {
    depositor = ethers.provider.getSigner(0);
    beneficiary = ethers.provider.getSigner(1);
    arbiter = ethers.provider.getSigner(2);
    const Escrow = await ethers.getContractFactory('Escrow');
    contract = await Escrow.deploy(
      arbiter.getAddress(),
      beneficiary.getAddress(),
      {
        value: deposit,
      }
    );
    await contract.deployed();
  });

  it('should be funded initially', async function () {
    let balance = await ethers.provider.getBalance(contract.address);
    expect(balance).to.eq(deposit);
  });

  describe('after approval from address other than the arbiter', () => {
    it('should revert', async () => {
      await expect(contract.connect(beneficiary).approve()).to.be.reverted;
    });
  });

  describe('after approval from the arbiter', () => {
    it('should transfer balance to beneficiary', async () => {
      const before = await ethers.provider.getBalance(beneficiary.getAddress());
      const approveTxn = await contract.connect(arbiter).approve();
      await approveTxn.wait();
      const after = await ethers.provider.getBalance(beneficiary.getAddress());
      expect(after.sub(before)).to.eq(deposit);
    });
  });

  describe('after cancellation by the arbiter', () => {
    it('should transfer balance back to depositor', async () => {
      const before = await ethers.provider.getBalance(depositor.getAddress());
      const cancelTxn = await contract.connect(arbiter).cancel();
      await cancelTxn.wait();
      const after = await ethers.provider.getBalance(depositor.getAddress());
      expect(after.sub(before)).to.eq(deposit);
    });
  
    it('should not allow beneficiary to approve after cancellation', async () => {
      const cancelTxn = await contract.connect(arbiter).cancel();
      await cancelTxn.wait();
      await expect(contract.connect(beneficiary).approve()).to.be.reverted;
    });
  });

  describe('startDispute', () => {
    it('should emit DisputeStarted event', async () => {
      const startDisputeTxn = await contract.connect(beneficiary).startDispute();
      await startDisputeTxn.wait();
      const events = await contract.queryFilter('DisputeStarted');
      expect(events.length).to.equal(1);
    });
  
    it('should revert if the transaction is already approved', async () => {
      await contract.connect(arbiter).approve();
      await expect(contract.connect(beneficiary).startDispute()).to.be.revertedWith('Transaction already approved');
    });
  
    it('should revert if an invalid caller tries to start dispute', async () => {
      await expect(contract.connect(depositor).startDispute()).to.be.revertedWith('Invalid caller');
    });
  });
  
  
});