const BNSDomainNamesMarket = artifacts.require('BNSDomainNamesMarket');
const BNSMarketPricePolicy = artifacts.require('BNSMarketPricePolicy');
const BNSNamesPolicy = artifacts.require('BNSNamesPolicy');
const BNSNFT = artifacts.require('BNSNFT');
const { logger } = require('./util');

async function deploy () {
  const { log } = logger(await web3.eth.net.getNetworkType());
  const [deployer] = await web3.eth.getAccounts();

  const market = await BNSDomainNamesMarket.new({ from: deployer });
  log(`Market deployed: @address{${market.address}}`);

  const pricing = await BNSMarketPricePolicy.new({ from: deployer });
  log(`PricingController deployed: @address{${pricing.address}}`);

  const names = await BNSNamesPolicy.new({ from: deployer });
  log(`DomainNamesController deployed: @address{${names.address}}`);

  const nft = await BNSNFT.new({ from: deployer });
  log(`NFT deployed: @address{${nft.address}}`);
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
