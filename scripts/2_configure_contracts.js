const BNSDomainNamesMarket = artifacts.require('BNSDomainNamesMarket');
const BNSMarketPricePolicy = artifacts.require('BNSMarketPricePolicy');
const { logger } = require('./util');
const { ether, time, BN} = require('@openzeppelin/test-helpers');

const SIZES = [1,2,3,4,5,6,7,8];
const PRICES_USDT = [300000,250000,200000,100000,50000,10000,1000,100];


async function deploy () {
  const args = process.argv.slice(2);
  const MARKET_ADDRESS = args[args.findIndex(argName => argName === '--market') + 1];
  const DOMAIN_NAMES_CONTROLLER_ADDRESS = args[args.findIndex(argName => argName === '--names') + 1];
  const PRICING_CONTROLLER_ADDRESS = args[args.findIndex(argName => argName === '--pricing') + 1];
  const { log } = logger(await web3.eth.net.getNetworkType());
  const [deployer] = await web3.eth.getAccounts();

  const market = await BNSDomainNamesMarket.at(MARKET_ADDRESS);
  const pricingController = await BNSMarketPricePolicy.at(PRICING_CONTROLLER_ADDRESS);

  {
    log(`Market. Set NFT.`);
    const tx = await market.setBNSNFT(bnsnft, {from: deployer});
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
    log(`PricingController. Set prices.`);
    const tx = await pricingController.setPrices(SIZES, PRICES_USDT, 30, {from: deployer});
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
