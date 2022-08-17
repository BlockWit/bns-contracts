const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');

const PaymentHelperMock = contract.fromArtifact('PaymentHelperMock');
const ERC20Mock = contract.fromArtifact('ERC20Mock');

const [ owner, user ] = accounts;


describe('PaymentHelper', function () {
  let paymentHelper;
  let tokens;

  beforeEach(async function () {
    paymentHelper = await PaymentHelperMock.new({ from: owner });
    tokens = await Promise.all([
      ERC20Mock.new('First Mock Token', 'FRST', owner, ether('10000'), { from: owner }),
      ERC20Mock.new('Second Mock Token', 'SCND', owner, ether('20000'), { from: owner }),
      ERC20Mock.new('Third Mock token', 'THRD', owner, ether('30000'), { from: owner })
    ])
  });

  describe('setToken', function () {
    it('should add specified token at specified index to contract', async function () {

    });
  });
  describe('removeToken', function () {
    it('should remove token at specified index correctly', async function () {

    });
  });
  describe('transfer', function () {
    it('should work correctly with any of the specified tokens', async function () {

    });
  });
});
