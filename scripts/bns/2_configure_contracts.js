const BNSDomainNamesMarket = artifacts.require('BNSDomainNameMarket');
const BNSMarketPricePolicy = artifacts.require('BNSMarketPricePolicy');
const BNSNFT = artifacts.require('BNSNFT');
const BNSContentRouter = artifacts.require('BNSContentRouter');
const BNSSimpleContentProvider = artifacts.require('BNSSimpleContentProvider');
const { logger } = require('../util');
const { ether, time, BN} = require('@openzeppelin/test-helpers');

const SIZES = [1,2,3,4,5,6,7,8];
const PRICES_USDT = [300000,250000,200000,100000,50000,10000,1000,100];


async function deploy () {
  const args = process.argv.slice(2);
  const DOMAIN_NAMES_CONTROLLER_ADDRESS = args[args.findIndex(argName => argName === '--names') + 1];
  const MARKET_ADDRESS = args[args.findIndex(argName => argName === '--market') + 1];
  const NFT_ADDRESS = args[args.findIndex(argName => argName === '--nft') + 1];
  const PRICING_CONTROLLER_ADDRESS = args[args.findIndex(argName => argName === '--pricing') + 1];
  const ROUTER_ADDRESS = args[args.findIndex(argName => argName === '--router') + 1];
  const PROVIDER_ADDRESS = args[args.findIndex(argName => argName === '--provider') + 1];
  const DIVIDENDS_ADDRESS = args[args.findIndex(argName => argName === '--dividends') + 1];
  const BUSD_ADDRESS = args[args.findIndex(argName => argName === '--busd') + 1];
  const USDT_ADDRESS = args[args.findIndex(argName => argName === '--usdt') + 1];
  const { log } = logger(await web3.eth.net.getNetworkType());
  const [deployer] = await web3.eth.getAccounts();

  const nft = await BNSNFT.at(NFT_ADDRESS);
  const market = await BNSDomainNamesMarket.at(MARKET_ADDRESS);
  const pricingController = await BNSMarketPricePolicy.at(PRICING_CONTROLLER_ADDRESS);
  const contentRouter = await BNSContentRouter.at(ROUTER_ADDRESS);
  const contentProvider = await BNSSimpleContentProvider.at(PROVIDER_ADDRESS);

  {
    log(`NFT. Grant minter role to Market.`);
    const tx = await nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`NFT. Set content router.`);
    const tx = await nft.setContentRouter(ROUTER_ADDRESS, {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`ContentRouter. Grant content manager role to NFT.`);
    const tx = await contentRouter.grantRole(web3.utils.keccak256('CONTENT_MANAGER'), nft.address, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`ContentRouter. Set content provider.`);
    const tx = await contentRouter.setDefaultContentProvider(PROVIDER_ADDRESS, {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`ContentProvider. Grant content manager role to ContentRouter.`);
    const tx = await contentProvider.grantRole(web3.utils.keccak256('CONTENT_MANAGER'), contentRouter.address, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set NFT.`);
    const tx = await market.setBNSNFT(NFT_ADDRESS, {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set PricingController.`);
    const tx = await market.setPricePolicy(PRICING_CONTROLLER_ADDRESS, {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set DomainNamesController.`);
    const tx = await market.setNamesPolicy(DOMAIN_NAMES_CONTROLLER_ADDRESS, {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set BUSD.`);
    const tx = await market.setAsset(BUSD_ADDRESS, 'BUSD', 1, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set USDT.`);
    const tx = await market.setAsset(USDT_ADDRESS, 'USDT', 1, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set fundraising wallet.`);
    const tx = await market.setDividendManager(DIVIDENDS_ADDRESS, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`PricingController. Set prices.`);
    const tx = await pricingController.setPrices(ether('30'), SIZES, PRICES_USDT.map(price => ether(price.toString())), {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
}

module.exports = async function main (callback) {
  try {
    await deploy();
    console.log('success');
    callback(null);
  } catch (e) {
    console.log('error');
    console.log(e);
    callback(e);
  }
};
