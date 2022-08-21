const BNSDomainNamesMarket = artifacts.require('BNSDomainNameMarket');
const BNSMarketPricePolicy = artifacts.require('BNSMarketPricePolicy');
const BNSNFT = artifacts.require('BNSNFT');
const BNSToken = artifacts.require('BNSToken');
const { logger } = require('./util');
const { ether, time, BN} = require('@openzeppelin/test-helpers');

const SIZES = [1,2,3,4,5,6,7,8];
const PRICES_USDT = [300000,250000,200000,100000,50000,10000,1000,100];


async function deploy () {
  const args = process.argv.slice(2);
  const DOMAIN_NAMES_CONTROLLER_ADDRESS = args[args.findIndex(argName => argName === '--names') + 1];
  const MARKET_ADDRESS = args[args.findIndex(argName => argName === '--market') + 1];
  const NFT_ADDRESS = args[args.findIndex(argName => argName === '--nft') + 1];
  const PRICING_CONTROLLER_ADDRESS = args[args.findIndex(argName => argName === '--pricing') + 1];
  const TOKEN_ADDRESS = args[args.findIndex(argName => argName === '--token') + 1];
  const BUSD_ADDRESS = args[args.findIndex(argName => argName === '--busd') + 1];
  const USDT_ADDRESS = args[args.findIndex(argName => argName === '--usdt') + 1];
  const { log } = logger(await web3.eth.net.getNetworkType());
  const [deployer] = await web3.eth.getAccounts();

  const nft = await BNSNFT.at(NFT_ADDRESS);
  const market = await BNSDomainNamesMarket.at(MARKET_ADDRESS);
  const pricingController = await BNSMarketPricePolicy.at(PRICING_CONTROLLER_ADDRESS);
  const token = await BNSToken.at(TOKEN_ADDRESS);

  {
    log(`NFT. Grant minter role to Market.`);
    const tx = await nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer });
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
    const tx = await market.setDividendManager(TOKEN_ADDRESS, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Token. Set BUSD.`);
    const tx = await token.setAsset(BUSD_ADDRESS, 'BUSD', 1, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set USDT.`);
    const tx = await token.setAsset(USDT_ADDRESS, 'USDT', 1, { from: deployer });
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
