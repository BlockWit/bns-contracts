const { execSync } = require('child_process')
const { logger } = require('./util');

const args = process.argv.slice(2);
const network = args[args.findIndex(argName => argName === '--network') + 1];
const { addresses } = logger(network);

const contracts = addresses.claim([
  'InvestNFTMarket',
  'InvestNFT',
  'InvestNFTMarketPricePolicy',
  'DividendManager',
  'BNSNFT',
  'BNSDomainNameMarket',
  'BNSMarketPricePolicy',
  'BNSNamesPolicy',
  'BNSContentRouter',
  'BNSSimpleContentProvider',
])

for (const [name, address] of Object.entries(contracts)) {
  execSync(`npx truffle run verify ${name}@${address} --network ${network}`, {stdio: 'inherit'});
}
