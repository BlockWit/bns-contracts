const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');

const AssetHandlerMock = contract.fromArtifact('AssetHandlerMock');
const ERC20Mock = contract.fromArtifact('ERC20Mock');

const [ owner, user ] = accounts;


describe('AssetHandler', function () {
  let AssetHandler;
  let tokens;

  beforeEach(async function () {
    AssetHandler = await AssetHandlerMock.new({ from: owner });
    tokens = await Promise.all([
      ERC20Mock.new('First Mock Token', 'FRST', owner, ether('10000'), { from: owner }),
      ERC20Mock.new('Second Mock Token', 'SCND', owner, ether('20000'), { from: owner }),
      ERC20Mock.new('Third Mock token', 'THRD', owner, ether('30000'), { from: owner })
    ])
  });

  describe('setAsset', function () {
    it('should add specified token at specified index to contract', async function () {

    });
  });
  describe('removeAsset', function () {
    it('should remove token at specified index correctly', async function () {

    });
  });
  describe('transfer', function () {
    it('should work correctly with any of the specified tokens', async function () {

    });
  });
});
