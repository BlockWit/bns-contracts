const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');
const { getEvents } = require('./util');

const BNSDomainNameMarket = contract.fromArtifact('BNSDomainNameMarket');
const BNSMarketPricePolicy = contract.fromArtifact('BNSMarketPricePolicy');
const BNSNamesPolicy = contract.fromArtifact('BNSNamesPolicy');
const BNSNFT = contract.fromArtifact('BNSNFT');
const PaymentHelper = contract.fromArtifact('PaymentHelper');
const ERC20Mock = contract.fromArtifact('ERC20Mock');

const SIZES = [1,2,3,4,5,6,7,8];
const PRICES_USDT = [300000,250000,200000,100000,50000,10000,1000,100];
const BASE_PRICE_USDT = 100;

const [ deployer, fundraisingWallet, user ] = accounts;

describe('BNSDomainNameMarket', function () {
  let market;
  let names;
  let nft;
  let pricing;
  let payment;
  let tokens = { usdt: { id: 1, contract: undefined, key: 12345 }, busd: { id: 2, contract: undefined, key: 23456 }};

  beforeEach(async function () {
    [ market, names, nft, pricing, payment, tokens.busd.contract, tokens.usdt.contract ] = await Promise.all([
      BNSDomainNameMarket.new({ from: deployer }),
      BNSNamesPolicy.new({ from: deployer }),
      BNSNFT.new({ from: deployer }),
      BNSMarketPricePolicy.new({ from: deployer }),
      PaymentHelper.new({ from: deployer}),
      ERC20Mock.new('BUSD Mock Token', 'BUSD', deployer, ether('10000000'), { from: deployer }),
      ERC20Mock.new('USDT Mock Token', 'USDT', deployer, ether('10000000'), { from: deployer }),
    ]);
    await Promise.all([
      tokens.busd.contract.transfer(user, ether('5000000'), { from: deployer}),
      tokens.usdt.contract.transfer(user, ether('5000000'), { from: deployer})
    ])
  });

  describe('setBNSNFT', function () {
    context('when called by admin', function () {
      it('should change bnsnft', async function () {
        await market.setBNSNFT(nft.address, {from : deployer});
        expect(await market.bnsnft()).to.be.equal(nft.address);
      });
    });
    context('when called not by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(market.setBNSNFT(nft.address, {from : user}));
      });
    });
  });

  describe('setFundraisingWallet', function () {
    context('when called by admin', function () {
      it('should change fundraisingWallet', async function () {
        await market.setFundraisingWallet(fundraisingWallet, {from : deployer});
        expect(await market.fundraisingWallet()).to.be.equal(fundraisingWallet);
      });
    });
    context('when called not by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(market.setFundraisingWallet(fundraisingWallet, {from : user}));
      });
    });
  });

  describe('setPricePolicy', function () {
    context('when called by admin', function () {
      it('should change pricePolicy', async function () {
        await market.setPricePolicy(pricing.address, {from : deployer});
        expect(await market.pricePolicy()).to.be.equal(pricing.address);
      });
    });
    context('when called not by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(market.setPricePolicy(pricing.address, {from : user}));
      });
    });
  });

  describe('setNamesPolicy', function () {
    context('when called by admin', function () {
      it('should change namesPolicy', async function () {
        await market.setNamesPolicy(names.address, {from : deployer});
        expect(await market.namesPolicy()).to.be.equal(names.address);
      });
    });
    context('when called not by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(market.setNamesPolicy(names.address, {from : user}));
      });
    });
  });

  describe('setToken', function () {
    context('when called by admin', function () {
      it('should add token to tokens.map', async function () {
        await market.setToken(tokens.usdt.key, tokens.usdt.contract.address, 1, {from : deployer});
        const tempToken = await payment.getToken(tokens.usdt.key);

      });
    });
    context('when called not by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(market.setToken(tokens.usdt.key, tokens.usdt.contract.address, 1, {from : user}));
      });
    });
  });

  describe('removeToken', function () {
    it('should remove token', async function () {
      // expect(await market.removeToken(tokens.usdt.id, {from : deployer})).to.be.equal(true);
    });
  });

  describe('buy', function () {
    beforeEach(async function () {
      await Promise.all([
        nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer }),
        market.setFundraisingWallet(fundraisingWallet, { from: deployer }),
        market.setBNSNFT(nft.address, { from: deployer }),
        market.setPricePolicy(pricing.address, { from: deployer }),
        market.setNamesPolicy(names.address, { from: deployer}),
        market.setToken(tokens.usdt.id, tokens.usdt.contract.address, 1, { from: deployer }),
        market.setToken(tokens.busd.id, tokens.busd.contract.address, 1, { from: deployer }),
        pricing.setPrices(ether(BASE_PRICE_USDT.toString()), SIZES, PRICES_USDT.map(price => ether(price.toString())), { from: deployer })
      ])
    });

    it('should transfer nft to buyer', async function () {
      await tokens.usdt.contract.approve(market.address, ether('250000'), { from: user });
      const { tx } = await market.buy('ab', tokens.usdt.id, { from: user });
      const [{ args: { from, to, tokenId }}] = await getEvents(tx, nft, 'Transfer', web3);
      expect(from).to.be.equal(constants.ZERO_ADDRESS);
      expect(to).to.be.equal(user);
      expect(tokenId).to.be.bignumber.equal(new BN('0'));
    });

    it('should transfer USD to fundraising wallet', async function () {
      await tokens.usdt.contract.approve(market.address, ether('250000'), { from: user });
      const { tx } = await market.buy('ab', tokens.usdt.id, { from: user });
      const [{ args: { from, to, value }}] = await getEvents(tx, tokens.usdt.contract, 'Transfer', web3);
      expect(from).to.be.equal(user);
      expect(to).to.be.equal(fundraisingWallet);
      expect(value).to.be.bignumber.equal(ether('250000'));
    });
  });
});
