const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');
const { getEvents } = require('./util');

const BNSDomainNameMarket = contract.fromArtifact('BNSDomainNameMarket');
const BNSMarketPricePolicy = contract.fromArtifact('BNSMarketPricePolicy');
const BNSNamesPolicy = contract.fromArtifact('BNSNamesPolicy');
const BNSNFT = contract.fromArtifact('BNSNFT');
const BNSToken = contract.fromArtifact('BNSToken');
const ERC20Mock = contract.fromArtifact('ERC20Mock');

const SIZES = [1,2,3,4,5,6,7,8];
const PRICES_USDT = [300000,250000,200000,100000,50000,10000,1000,100];
const BASE_PRICE_USDT = 100;

const [ deployer, user ] = accounts;

describe('BNSDomainNameMarket', function () {
  let market;
  let names;
  let nft;
  let pricing;
  let token;
  let tokens = { usdt: { id: 1, contract: undefined, key: 12345 }, busd: { id: 2, contract: undefined, key: 23456 }};

  beforeEach(async function () {
    [ market, names, nft, token, pricing, tokens.busd.contract, tokens.usdt.contract ] = await Promise.all([
      BNSDomainNameMarket.new({ from: deployer }),
      BNSNamesPolicy.new({ from: deployer }),
      BNSNFT.new({ from: deployer }),
      BNSToken.new({ from: deployer }),
      BNSMarketPricePolicy.new({ from: deployer }),
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

  describe('setIDividendManager', function () {
    context('when called by admin', function () {
      it('should change address of the dividend manager', async function () {
        await market.setIDividendManager(token.address, {from : deployer});
        expect(await market.dividendManager()).to.be.equal(token.address);
      });
    });
    context('when called not by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(market.setIDividendManager(token.address, {from : user}));
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

  describe('setAsset', function () {
    context('when called by admin', function () {
      it('should add specified asset to assets.map', async function () {
        await market.setAsset(tokens.usdt.contract.address, 'USDT', 1, {from : deployer});
        const [ticker, type] = await market.getAsset(tokens.usdt.contract.address);
        expect(ticker).to.be.equal('USDT');
        expect(type).to.be.equal('1');
      });
    });
    context('when called not by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(market.setAsset(tokens.busd.contract.address, 'BUSD', 1, {from : user}));
      });
    });
  });

  describe('removeAsset', function () {
    context('if asset is added', function () {
      it('should remove specified asset', async function () {
        await market.setAsset(tokens.usdt.contract.address, 'USDT', 1, {from : deployer});
        const [ticker, type] = await market.getAsset(tokens.usdt.contract.address);
        expect(ticker).to.be.equal('USDT');
        expect(type).to.be.equal('1');
        await market.removeAsset(tokens.usdt.contract.address, {from : deployer});
        await expectRevert(market.getAsset(tokens.usdt.contract.address), 'Assets.Map: nonexistent key');
      });
    });
  });

  describe('getPrice', function () {
    beforeEach(async function () {
      await Promise.all([
        nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer }),
        market.setDividendManager(token.address, { from: deployer }),
        market.setBNSNFT(nft.address, { from: deployer }),
        market.setPricePolicy(pricing.address, { from: deployer }),
        market.setNamesPolicy(names.address, { from: deployer}),
        market.setAsset(tokens.usdt.contract.address, 'USDT', 1, {from : deployer}),
        market.setAsset(tokens.busd.contract.address, 'BUSD', 1, {from : deployer}),
        token.setAsset(tokens.usdt.contract.address, 'USDT', 1, {from : deployer}),
        token.setAsset(tokens.busd.contract.address, 'BUSD', 1, {from : deployer}),
        pricing.setPrices(ether(BASE_PRICE_USDT.toString()), SIZES, PRICES_USDT.map(price => ether(price.toString())), { from: deployer })
      ])
    });

    context('if domainName doesn`t exist', function () {
      it('should return price for specified domainName', async function () {
        expect (await market.getPrice('Hahaha', tokens.usdt.contract.address)).to.be.bignumber.equal(ether('10000'));
      });
    });
    context('if domainName exists', function () {
      it('revert', async function () {
        await tokens.usdt.contract.approve(market.address, ether('250000'), {from: user});
        await market.buy('aba', tokens.usdt.contract.address, {from: user});
        await expectRevert(market.getPrice('aba', tokens.usdt.contract.address, {from: user}),
            'Domain name already exists');
      });
    });
  });

  describe('buy', function () {
    beforeEach(async function () {
      await Promise.all([
        nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer }),
        market.setDividendManager(token.address, { from: deployer }),
        market.setBNSNFT(nft.address, { from: deployer }),
        market.setPricePolicy(pricing.address, { from: deployer }),
        market.setNamesPolicy(names.address, { from: deployer}),
        market.setAsset(tokens.usdt.contract.address, 'USDT', 1, {from : deployer}),
        market.setAsset(tokens.busd.contract.address, 'BUSD', 1, {from : deployer}),
        token.setAsset(tokens.usdt.contract.address, 'USDT', 1, {from : deployer}),
        token.setAsset(tokens.busd.contract.address, 'BUSD', 1, {from : deployer}),
        pricing.setPrices(ether(BASE_PRICE_USDT.toString()), SIZES, PRICES_USDT.map(price => ether(price.toString())), { from: deployer })
      ])
    });

    context('if domain doesn`t exist', function () {
      it('should transfer nft to buyer', async function () {
        await tokens.usdt.contract.approve(market.address, ether('250000'), { from: user });
        const { tx } = await market.buy('ab', tokens.usdt.contract.address, { from: user });
        const [{ args: { from, to, tokenId }}] = await getEvents(tx, nft, 'Transfer', web3);
        expect(from).to.be.equal(constants.ZERO_ADDRESS);
        expect(to).to.be.equal(user);
        expect(tokenId).to.be.bignumber.equal(new BN('0'));
      });
      it('should transfer USD to fundraising wallet', async function () {
        await tokens.usdt.contract.approve(market.address, ether('250000'), { from: user });
        const { tx } = await market.buy('ab', tokens.usdt.contract.address, { from: user });
        const res = await getEvents(tx, tokens.usdt.contract, 'Transfer', web3);
        const [, { args: { from, to, value }}] = await getEvents(tx, tokens.usdt.contract, 'Transfer', web3);
        expect(from).to.be.equal(market.address);
        expect(to).to.be.equal(token.address);
        expect(value).to.be.bignumber.equal(ether('250000'));
      });
    });
    context('if domain exists', function () {
      it('revert', async function () {
        await tokens.usdt.contract.approve(market.address, ether('250000'), {from: user});
        await market.buy('ab', tokens.usdt.contract.address, {from: user});
        await expectRevert(market.buy('ab', tokens.usdt.contract.address, {from: user}),
            'Domain name already exists');
      });
    });
  });
});
