const BNSDomainNameMarket = artifacts.require('BNSDomainNameMarket');
const BNSMarketPricePolicy = artifacts.require('BNSMarketPricePolicy');
const BNSNamesPolicy = artifacts.require('BNSNamesPolicy');
const BNSNFT = artifacts.require('BNSNFT');
const BNSContentRouter = artifacts.require('BNSContentRouter');
const BNSSimpleContentProvider = artifacts.require('BNSSimpleContentProvider');
const { logger } = require('../util');

async function deploy () {
  const { log, logAddress } = logger(config.network);
  const [deployer] = await web3.eth.getAccounts();

  const market = await BNSDomainNameMarket.new({ from: deployer });
  log(`BNSDomainNameMarket deployed: @address{${market.address}}`);
  logAddress('BNSDomainNameMarket', market.address);

  const pricing = await BNSMarketPricePolicy.new({ from: deployer });
  log(`BNSMarketPricePolicy deployed: @address{${pricing.address}}`);
  logAddress('BNSMarketPricePolicy', pricing.address);

  const names = await BNSNamesPolicy.new({ from: deployer });
  log(`BNSNamesPolicy deployed: @address{${names.address}}`);
  logAddress('BNSNamesPolicy', names.address);

  const nft = await BNSNFT.new({ from: deployer });
  log(`BNSNFT deployed: @address{${nft.address}}`);
  logAddress('BNSNFT', nft.address);

  const router = await BNSContentRouter.new({ from: deployer });
  log(`BNSContentRouter deployed: @address{${router.address}}`);
  logAddress('BNSContentRouter', router.address);

  const provider = await BNSSimpleContentProvider.new({ from: deployer });
  log(`BNSSimpleContentProvider deployed: @address{${provider.address}}`);
  logAddress('BNSSimpleContentProvider', provider.address);

  const contracts = [
    { contract: market, name: 'BNSDomainNameMarket' },
    { contract: pricing, name: 'BNSMarketPricePolicy' },
    { contract: names, name: 'BNSNamesPolicy' },
    { contract: nft, name: 'BNSNFT' },
    { contract: router, name: 'BNSContentRouter' },
    { contract: provider, name: 'BNSSimpleContentProvider' },
  ]

  log(Object.entries({ market, pricing, names, nft, router, provider }).reduce((result, [key, contract]) => {
    return `${result} --${key} ${contract.address}`
  }, 'Configuration params:'));

  log(contracts.reduce((result, { contract, name }) => {
    return `${result} ${name}@${contract.address}`
  }, 'Verification params: npx truffle run verify'));

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
