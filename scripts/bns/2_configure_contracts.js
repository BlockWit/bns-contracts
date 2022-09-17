const BNSDomainNameMarket = artifacts.require('BNSDomainNameMarket');
const BNSMarketPricePolicy = artifacts.require('BNSMarketPricePolicy');
const BNSNFT = artifacts.require('BNSNFT');
const BNSContentRouter = artifacts.require('BNSContentRouter');
const BNSSimpleContentProvider = artifacts.require('BNSSimpleContentProvider');
const { logger } = require('../util');
const { ether, time, BN} = require('@openzeppelin/test-helpers');

const SIZES = [1,2,3,4,5,6,7,8];
const PRICES_USDT = [300000,250000,200000,100000,50000,10000,1000,100];
const SPECIAL_PRICES_USDT = [300001,250001,200001,100001,50001,10001,1001,101];
let UTF8_RANGES = [
  ['4E00', '62FF'], ['6300', '77FF'], ['7800', '8CFF'], ['8D00', '9FFF'], // (CJK Unified Ideographs https://en.wikipedia.org/wiki/CJK_Unified_Ideographs)
  ['3400', '4DBF'], //  (CJK Unified Ideographs Extension A)
  ['20000', '215FF'], ['21600', '230FF'], ['23100', '245FF'], ['24600', '260FF'], ['26100', '275FF'], ['27600', '290FF'], ['29100', '2A6DF'], //  (CJK Unified Ideographs Extension B)
  ['2A700', '2B73F'], //  (CJK Unified Ideographs Extension C)
  ['2B740', '2B81F'], //  (CJK Unified Ideographs Extension D)
  ['2B820', '2CEAF'], //  (CJK Unified Ideographs Extension E)
  ['2CEB0', '2EBEF'], //  (CJK Unified Ideographs Extension F)
  ['30000', '3134F'], //  (CJK Unified Ideographs Extension G)
  ['F900', 'FAFF'], //  (CJK Compatibility Ideographs)
  ['0600', '06FF'], //  (Arabic https://en.wikipedia.org/wiki/Arabic_script_in_Unicode)
  ['0750', '077F'], //  (Arabic Supplement)
  ['08A0', '08FF'], //  (Arabic Extended-A)
  ['0870', '089F'], //  (Arabic Extended-B)
  ['FB50', 'FDFF'], //  (Arabic Presentation Forms-A)
  ['FE70', 'FEFF'], //  (Arabic Presentation Forms-B)
]

async function deploy () {
  const { addresses, log } = logger(config.network);
  const {
    BNSNFT: NFT_ADDRESS,
    BNSDomainNameMarket: MARKET_ADDRESS,
    BNSMarketPricePolicy: PRICING_CONTROLLER_ADDRESS,
    BNSNamesPolicy: DOMAIN_NAMES_CONTROLLER_ADDRESS,
    BNSContentRouter: ROUTER_ADDRESS,
    BNSSimpleContentProvider: PROVIDER_ADDRESS,
    DividendManager: DIVIDENDS_ADDRESS,
    BUSD: BUSD_ADDRESS,
    USDT: USDT_ADDRESS,
  } = addresses.claim([
    'BNSNFT',
    'BNSDomainNameMarket',
    'BNSMarketPricePolicy',
    'BNSNamesPolicy',
    'BNSContentRouter',
    'BNSSimpleContentProvider',
    'DividendManager',
    'BUSD',
    'USDT'
  ])
  const [deployer] = await web3.eth.getAccounts();

  const nft = await BNSNFT.at(NFT_ADDRESS);
  const market = await BNSDomainNameMarket.at(MARKET_ADDRESS);
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
  {
    log(`PricingController. Set prices for symbols within special range.`);
    const tx = await pricingController.setPricesForSymbolsWithinRange(ether('31'), SIZES, SPECIAL_PRICES_USDT.map(price => ether(price.toString())), {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`PricingController. Set UTF8 ranges.`);
    const tx = await pricingController.addUTF8Ranges(optimizeRanges(codesToHexes(UTF8_RANGES)).map(range => range.map(border => `0x${border}`)), {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
}

function codesToHexes(ranges) {
  ranges.forEach((range) => {
    range.forEach((code) => {
      code = unescape(encodeURIComponent(String.fromCharCode(parseInt(code, 16))))
          .split('')
          .map(v => { return v.charCodeAt(0).toString(16);})
          .join('');
    })
  })
  return ranges;
}

function optimizeRanges(ranges) {
  ranges = ranges.map(range => range.map(num => parseInt(num, 16)));
  ranges.sort((a, b) => a[0] - b[0]);
  let result = [];
  for (const range of ranges) {
    const [first, last] = range;
    let doesExtend = false;
    for (let i = 0; i < result.length; i++) {
      if (first === result[i][1] + 1) {
        result[i][1] = last;
        doesExtend = true;
        break;
      }
    }
    if (!doesExtend) result.push([first, last]);
  }
  result = result.map(range => range.map(num => num.toString(16).padStart(8, '0')));
  return result;
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
