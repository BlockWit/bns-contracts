const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');

const PaymentController = contract.fromArtifact('PaymentController');

const [user, owner ] = accounts;


describe('PaymentController', function () {
  let paymentController;

  beforeEach(async function () {
    paymentController = await PaymentController.new({ from: owner });
  });

  describe('total supply', function () {
    it('returns the total amount of tokens', async function () {
      const totalSupply = initialBalances.reduce((acc, val) => acc.add(val), ether('0'));
      expect(await token.totalSupply()).to.be.bignumber.equal(totalSupply);
    });
  });
});
