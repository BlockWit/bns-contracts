const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');

const AssetHandlerMock = contract.fromArtifact('AssetHandlerMock');
const ERC20Mock = contract.fromArtifact('ERC20Mock');

const [ owner, user ] = accounts;


describe('AssetHandler', function () {
  let assetHandler;
  let tokens = {
    frst: { id: 1, contract: undefined,  ticker: 'frst' },
    scnd: { id: 2, contract: undefined,  ticker: 'scnd' },
    thrd: { id: 3, contract: undefined,  ticker: 'thrd'
    }};

  beforeEach(async function () {
    assetHandler = await AssetHandlerMock.new({ from: owner });
    [ tokens.frst.contract, tokens.scnd.contract, tokens.thrd.contract ] = await Promise.all([
      ERC20Mock.new('First Mock Token', 'FRST', owner, ether('10000'), { from: owner }),
      ERC20Mock.new('Second Mock Token', 'SCND', owner, ether('20000'), { from: owner }),
      ERC20Mock.new('Third Mock token', 'THRD', owner, ether('30000'), { from: owner })
    ])
  });

  describe('setAsset', function () {
    it('should add specified asset at specified index to contract', async function () {
      await assetHandler.setAsset(tokens.frst.id, tokens.frst.ticker, 1, tokens.frst.contract.address, {from : owner});
      const assetFromMap = await assetHandler.getAsset(tokens.frst.id);
      const tempAsset = ['frst', "1", tokens.frst.contract.address];
      expect(assetFromMap[0]).to.be.equal(tempAsset[0]);
      expect(assetFromMap[1]).to.be.equal(tempAsset[1]);
      expect(assetFromMap[2]).to.be.equal(tempAsset[2]);
    });
  });
  describe('removeAsset', function () {
    it('should remove asset at specified index correctly', async function () {
      await assetHandler.setAsset(tokens.frst.id, tokens.frst.ticker, 1, tokens.frst.contract.address, {from : owner});
      const assetFromMap = await assetHandler.getAssetAt(0);
      const { 0: key, 1: array} = { 0: '1', 1: ['frst', '1', tokens.frst.contract.address]};
      expect(assetFromMap[0]).to.be.bignumber.equal(key);
      expect(assetFromMap[1][0]).to.be.equal(array[0]);
      expect(assetFromMap[1][1]).to.be.equal(array[1]);
      expect(assetFromMap[1][2]).to.be.equal(array[2]);
      await assetHandler.removeAsset(tokens.frst.id, {from : owner});
      await expectRevert(assetHandler.getAsset(tokens.frst.id), 'Assets.Map: nonexistent key');
    });
  });
  describe('transfer', function () {
    it('should work correctly with any of the specified assets', async function () {

    });
  });
});
