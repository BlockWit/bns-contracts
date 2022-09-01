const {accounts, contract, web3} = require('@openzeppelin/test-environment');
const {BN, expectRevert, ether} = require('@openzeppelin/test-helpers');
const {expect} = require('chai');

const InvestNFT = contract.fromArtifact('InvestNFT');
const InvestNFTMarket = contract.fromArtifact('InvestNFTMarket');
const InvestNFTMarketPricePolicy = contract.fromArtifact('InvestNFTMarketPricePolicy');
const DividendManager = contract.fromArtifact('DividendManager');
const ERC20Mock = contract.fromArtifact('ERC20Mock');
const BNSDomainNameMarket = contract.fromArtifact('BNSDomainNameMarket');
const BNSMarketPricePolicy = contract.fromArtifact('BNSMarketPricePolicy');
const BNSNamesPolicy = contract.fromArtifact('BNSNamesPolicy');
const BNSNFT = contract.fromArtifact('BNSNFT');


const [ deployer, account1, account2 ] = accounts;
const PRICE = ether('0.000000000000000001');
const SIZES = [1,2,3,4,5,6,7,8];
const PRICES_USDT = [300000,250000,200000,100000,50000,10000,1000,100];
const BASE_PRICE_USDT = 100;

describe('Integration test', async () => {
  let dividendManager;
  let market
  let pricing
  let nft;
  let usdt;
  let bnsMarket;

  beforeEach(async function () {
    [ nft, dividendManager, market, pricing, usdt ] = await Promise.all([
      InvestNFT.new({ from: deployer }),
      DividendManager.new({ from: deployer }),
      InvestNFTMarket.new({ from: deployer }),
      InvestNFTMarketPricePolicy.new({ from: deployer }),
      ERC20Mock.new('USDT Pegged Token', 'USDT', account1, ether('2000000'), { from: deployer }),

    ]);
    await Promise.all([
      nft.setDividendManager(dividendManager.address, { from: deployer }),
      nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer }),
      dividendManager.setDepositary(nft.address, { from: deployer }),
      dividendManager.setAsset(usdt.address, 'USDT', 1, { from: deployer }),
      market.setInvestNFT(nft.address, { from: deployer }),
      market.setPricePolicy(pricing.address, { from: deployer }),
      market.setAsset(usdt.address, 'USDT', 1, { from: deployer }),
      pricing.setPrice(PRICE, { from: deployer })
    ]);
    {
      const [ market, names, nft, pricing ] = await Promise.all([
        BNSDomainNameMarket.new({ from: deployer }),
        BNSNamesPolicy.new({ from: deployer }),
        BNSNFT.new({ from: deployer }),
        BNSMarketPricePolicy.new({ from: deployer }),
      ]);
      bnsMarket = market;
      await Promise.all([
        await market.setBNSNFT(nft.address, {from : deployer}),
        await market.setDividendManager(dividendManager.address, {from : deployer}),
        await market.setPricePolicy(pricing.address, {from : deployer}),
        await market.setNamesPolicy(names.address, {from : deployer}),
        await market.setAsset(usdt.address, 'USDT', 1, {from : deployer}),
        await nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer }),
        pricing.setPrices(ether(BASE_PRICE_USDT.toString()), SIZES, PRICES_USDT.map(price => ether(price.toString())), { from: deployer })
      ])
    }
  });

  describe('BNSDOMainNameMarket.buy', function () {
    const share = ether('123');
    beforeEach(async () => {
      await usdt.approve(market.address, PRICE.mul(share), { from: account1 });
      await market.buyExactShares(share, usdt.address, { from: account1 });
    });
    it('should work as intended full buy', async function () {
      await usdt.approve(bnsMarket.address, ether('250000'), { from: account1 });
      await bnsMarket.buy('ab', '', usdt.address, { from: account1 });
      await nft.withdrawDividend({from: account1});
    });
    it('should work as intended short buy', async function () {
      await usdt.approve(bnsMarket.address, ether('250000'), { from: account1 });
      await bnsMarket.buyWithoutReferer('ab', usdt.address, { from: account1 });
      await nft.withdrawDividend({from: account1});
    });
  });

});
