const {accounts, contract, web3} = require('@openzeppelin/test-environment');
const {BN, expectRevert, ether, constants} = require('@openzeppelin/test-helpers');
const {expect} = require('chai');
const {getEvents} = require("./util");

const InvestNFT = contract.fromArtifact('InvestNFT');
const InvestNFTMarket = contract.fromArtifact('InvestNFTMarket');
const InvestNFTMarketPricePolicy = contract.fromArtifact('InvestNFTMarketPricePolicy');
const DividendManager = contract.fromArtifact('DividendManager');
const ERC20Mock = contract.fromArtifact('ERC20Mock');
const BNSDomainNameMarket = contract.fromArtifact('BNSDomainNameMarket');
const BNSNFT = contract.fromArtifact('BNSNFT');


const [ deployer, account1, holder1, holder2, holder3 ] = accounts;
const PRICE = ether('0.000000000000000001');
const SIZES = [1,2,3,4,5,6,7,8];
const PRICES_USDT = [300000,250000,200000,100000,50000,10000,1000,100];
const PRICES_FOR_SYMBOLS = [400000,350000,300000,200000,100000,50000,2000,200];
const BASE_PRICE_USDT = 100;
const domainNames = ['a', 'ab', 'abc', 'abcd', 'abcde'];
const UTF8_RANGES_BYTES = [
  [ '0x00000030', '0x00000039' ],
  [ '0x0000D880', '0x0000DBBF' ],
  [ '0x0000DD90', '0x0000DDBF' ],
  [ '0x00E0A1B0', '0x00E0A3BF' ],
  [ '0x00E39080', '0x00E4B6BF' ],
  [ '0x00E4B880', '0x00E9BFBF' ],
  [ '0x00EFA480', '0x00EFABBF' ],
  [ '0x00EFAD90', '0x00EFB7BF' ],
  [ '0x00EFB9B0', '0x00EFBBBF' ],
  [ '0xF0A08080', '0xF0AA9B9F' ],
  [ '0xF0AA9C80', '0xF0AEAFAF' ],
  [ '0xF0B08080', '0xF0B18D8F' ]
]

describe('Integration test', function () {
  this.timeout(0);
  let dividendManager;
  let market
  let pricing
  let nft;
  let usdt;
  let bnsMarket;
  let bnsNFT;

  beforeEach(async function () {
    [nft, dividendManager, market, pricing, usdt] = await Promise.all([
      InvestNFT.new({from: deployer}),
      DividendManager.new({from: deployer}),
      InvestNFTMarket.new({from: deployer}),
      InvestNFTMarketPricePolicy.new({from: deployer}),
      ERC20Mock.new('USDT Pegged Token', 'USDT', account1, ether('2000000'), {from: deployer}),

    ]);
    await Promise.all([
      nft.setDividendManager(dividendManager.address, {from: deployer}),
      nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, {from: deployer}),
      dividendManager.setDepositary(nft.address, {from: deployer}),
      dividendManager.setAsset(usdt.address, 'USDT', 1, {from: deployer}),
      market.setInvestNFT(nft.address, {from: deployer}),
      market.setPricePolicy(pricing.address, {from: deployer}),
      market.setAsset(usdt.address, 'USDT', 1, {from: deployer}),
      pricing.setPrice(PRICE, {from: deployer})
    ]);
    {
      const [market, nft] = await Promise.all([
        BNSDomainNameMarket.new({from: deployer}),
        BNSNFT.new({from: deployer}),
      ]);
      bnsMarket = market;
      bnsNFT = nft;
      await Promise.all([
        await market.setBNSNFT(nft.address, {from: deployer}),
        await market.setDividendManager(dividendManager.address, {from: deployer}),
        await market.setAsset(usdt.address, 'USDT', 1, {from: deployer}),
        await nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, {from: deployer})
      ])
    }
  });

  describe('BNSDOMainNameMarket', function () {
    const share = ether('0.0000000000001');
    beforeEach(async () => {
      await nft.safeMint(holder1, ether('0.0000000000003'), {from: deployer});
      await nft.safeMint(holder2, ether('0.0000000000003'), {from: deployer});
      await nft.safeMint(holder3, ether('0.0000000000002'), {from: deployer});
      await usdt.approve(market.address, PRICE.mul(share), {from: account1});
      await market.buyExactShares(share, usdt.address, {from: account1});

    });
    describe('buy', function () {
      context('if buy regular domainName', function () {
        it('should transfer nft to buyer', async function () {
          expect(await bnsMarket.getPriceWithoutReferer('名', usdt.address)).to.be.bignumber.equal(ether('300000'));
          await usdt.approve(bnsMarket.address, ether('100000'), {from: account1});
          expect(await bnsNFT.balanceOf(account1)).to.be.bignumber.equal('0');
          await bnsMarket.buy('abab', '', usdt.address, {from: account1});
          expect(await bnsNFT.balanceOf(account1)).to.be.bignumber.equal('1');
        });
        it('should transfer usd to dividend manager and distribute between share holders', async function () {
          expect(await dividendManager.withdrawableDividendOf(3, usdt.address)).to.be.bignumber.equal('0');
          await usdt.approve(bnsMarket.address, ether('100000'), {from: account1});
          await bnsMarket.buy('abab', '', usdt.address, {from: account1});
          expect(await dividendManager.withdrawableDividendOf(3, usdt.address)).to.be.bignumber.equal('11111111111111111111111');
          expect(await usdt.balanceOf(account1)).to.be.bignumber.equal('1899999999999999999900000');
          await nft.withdrawDividend({from: account1});
          expect(await usdt.balanceOf(account1)).to.be.bignumber.equal('1911111111111111111011111');
        });
      });

      context('if buy domainName starting with symbol', function () {
        it('should transfer nft to buyer', async function () {
          await usdt.approve(bnsMarket.address, ether('50000'), {from: account1});
          expect(await bnsNFT.balanceOf(account1)).to.be.bignumber.equal('0');
          await bnsMarket.buy('拿sdf', '', usdt.address, {from: account1});
          expect(await bnsNFT.balanceOf(account1)).to.be.bignumber.equal('1');
        });
        it('should transfer usd to dividend manager and distribute between share holders', async function () {
          expect(await dividendManager.withdrawableDividendOf(3, usdt.address)).to.be.bignumber.equal('0');
          await usdt.approve(bnsMarket.address, ether('50000'), {from: account1});
          await bnsMarket.buy('拿sdf', '', usdt.address, {from: account1});
          expect(await dividendManager.withdrawableDividendOf(3, usdt.address)).to.be.bignumber.equal('5555555555555555555555');
          expect(await usdt.balanceOf(account1)).to.be.bignumber.equal('1949999999999999999900000');
          await nft.withdrawDividend({from: account1});
          expect(await usdt.balanceOf(account1)).to.be.bignumber.equal('1955555555555555555455555');
        });
      });
    });

    describe('buyWithoutReferer', function () {
      it('should transfer nft to buyer', async function () {
        await usdt.approve(bnsMarket.address, ether('100000'), {from: account1});
        expect(await bnsNFT.balanceOf(account1)).to.be.bignumber.equal('0');
        await bnsMarket.buyWithoutReferer('abab', usdt.address, {from: account1});
        expect(await bnsNFT.balanceOf(account1)).to.be.bignumber.equal('1');
      });

      it('should transfer usd to dividend manager and distribute between share holders', async function () {
        expect(await dividendManager.withdrawableDividendOf(3, usdt.address)).to.be.bignumber.equal('0');
        await usdt.approve(bnsMarket.address, ether('100000'), {from: account1});
        await bnsMarket.buyWithoutReferer('abab', usdt.address, {from: account1});
        expect(await dividendManager.withdrawableDividendOf(3, usdt.address)).to.be.bignumber.equal('11111111111111111111111');
        expect(await usdt.balanceOf(account1)).to.be.bignumber.equal('1899999999999999999900000');
        await nft.withdrawDividend({from: account1});
        expect(await usdt.balanceOf(account1)).to.be.bignumber.equal('1911111111111111111011111');
      });
    });

    describe('buyBulk', function () {
      it('should transfer all nft to buyer', async function () {
        await usdt.approve(bnsMarket.address, ether('900000'), {from: account1});
        expect(await bnsNFT.balanceOf(account1)).to.be.bignumber.equal('0');
        await bnsMarket.buyBulk(domainNames, '', usdt.address, {from: account1});
        expect(await bnsNFT.balanceOf(account1)).to.be.bignumber.equal('5');
      });

      it('should transfer usd to dividend manager and distribute between share holders', async function () {
        expect(await dividendManager.withdrawableDividendOf(3, usdt.address)).to.be.bignumber.equal('0');
        await usdt.approve(bnsMarket.address, ether('900000'), {from: account1});
        await bnsMarket.buyBulk(domainNames, '', usdt.address, {from: account1});
        expect(await dividendManager.withdrawableDividendOf(3, usdt.address)).to.be.bignumber.equal('100000000000000000000000');
        expect(await usdt.balanceOf(account1)).to.be.bignumber.equal('1099999999999999999900000');
        await nft.withdrawDividend({from: account1});
        expect(await usdt.balanceOf(account1)).to.be.bignumber.equal('1199999999999999999900000');
      });
    });
  });
});