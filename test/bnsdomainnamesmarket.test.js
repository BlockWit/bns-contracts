const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');
const { getEvents } = require('./util');

const BNSDomainNameMarket = contract.fromArtifact('BNSDomainNameMarket');
const BNSMarketPricePolicy = contract.fromArtifact('BNSMarketPricePolicy');
const BNSNamesPolicy = contract.fromArtifact('BNSNamesPolicy');
const BNSNFT = contract.fromArtifact('BNSNFT');
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
  let tokens = { usdt: { id: 1, contract: undefined }, busd: { id: 2, contract: undefined }};

  beforeEach(async function () {
    [ market, names, nft, pricing, tokens.busd.contract, tokens.usdt.contract ] = await Promise.all([
      BNSDomainNameMarket.new({ from: deployer }),
      BNSNamesPolicy.new({ from: deployer }),
      BNSNFT.new({ from: deployer }),
      BNSMarketPricePolicy.new({ from: deployer }),
      ERC20Mock.new('BUSD Mock Token', 'BUSD', deployer, ether('10000000'), { from: deployer }),
      ERC20Mock.new('USDT Mock Token', 'USDT', deployer, ether('10000000'), { from: deployer }),
    ]);
    await Promise.all([
      tokens.busd.contract.transfer(user, ether('5000000'), { from: deployer}),
      tokens.usdt.contract.transfer(user, ether('5000000'), { from: deployer})
    ])
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
