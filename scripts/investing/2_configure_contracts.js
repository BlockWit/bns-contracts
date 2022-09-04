const InvestNFT = artifacts.require('InvestNFT');
const InvestNFTMarket = artifacts.require('InvestNFTMarket');
const InvestNFTMarketPricePolicy = artifacts.require('InvestNFTMarketPricePolicy');
const DividendManager = artifacts.require('DividendManager');
const { logger } = require('../util');
const { ether, time, BN} = require('@openzeppelin/test-helpers');


async function deploy () {
  const args = process.argv.slice(2);
  const MARKET_ADDRESS = args[args.findIndex(argName => argName === '--market') + 1];
  const NFT_ADDRESS = args[args.findIndex(argName => argName === '--nft') + 1];
  const PRICING_POLICY_ADDRESS = args[args.findIndex(argName => argName === '--pricing') + 1];
  const DIVIDEND_MANAGER_ADDRESS = args[args.findIndex(argName => argName === '--dividends') + 1];
  const BUSD_ADDRESS = args[args.findIndex(argName => argName === '--busd') + 1];
  const USDT_ADDRESS = args[args.findIndex(argName => argName === '--usdt') + 1];
  const DEV_ADDRESS = args[args.findIndex(argName => argName === '--devs') + 1];
  const TEAM_ADDRESS = args[args.findIndex(argName => argName === '--team') + 1];
  const FUND_ADDRESS = args[args.findIndex(argName => argName === '--fund') + 1];
  const { log } = logger(await web3.eth.net.getNetworkType());
  const [deployer] = await web3.eth.getAccounts();

  const nft = await InvestNFT.at(NFT_ADDRESS);
  const market = await InvestNFTMarket.at(MARKET_ADDRESS);
  const pricing = await InvestNFTMarketPricePolicy.at(PRICING_POLICY_ADDRESS);
  const dividendManager = await DividendManager.at(DIVIDEND_MANAGER_ADDRESS);

  {
    log(`NFT. Set DividendManager.`);
    const tx = await nft.setDividendManager(DIVIDEND_MANAGER_ADDRESS, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`NFT. Grant minter role to Market.`);
    const tx = await nft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set NFT.`);
    const tx = await market.setInvestNFT(NFT_ADDRESS, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`Market. Set PricingPolicy.`);
    const tx = await market.setPricePolicy(PRICING_POLICY_ADDRESS, {from: deployer});
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
    log(`DividendManager. Set depositary.`);
    const tx = await dividendManager.setDepositary(NFT_ADDRESS, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`DividendManager. Set BUSD.`);
    const tx = await dividendManager.setAsset(BUSD_ADDRESS, 'BUSD', 1, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`DividendManager. Set USDT.`);
    const tx = await dividendManager.setAsset(USDT_ADDRESS, 'USDT', 1, { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`PricingPolicy. Set price.`);
    const tx = await pricing.setPrice(ether('0.000000000000000001'), {from: deployer});
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`NFT. Mint dev shares.`);
    const tx = await nft.safeMint(DEV_ADDRESS, ether('0.000000000000300000'), { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`NFT. Mint team shares.`);
    const tx = await nft.safeMint(TEAM_ADDRESS, ether('0.000000000000300000'), { from: deployer });
    log(`Result: successful tx: @tx{${tx.receipt.transactionHash}}`);
  }
  {
    log(`NFT. Mint fund shares.`);
    const tx = await nft.safeMint(FUND_ADDRESS, ether('0.000000000000200000'), { from: deployer });
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
