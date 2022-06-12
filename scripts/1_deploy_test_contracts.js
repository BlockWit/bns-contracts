const BNSSimpleStorage = artifacts.require('BNSSimpleStorage');
const BNSRepository = artifacts.require('BNSRepository');
const { logger } = require('./util');
const { ether, time, BN} = require('@openzeppelin/test-helpers');

const SITE_NAME = "simple-site-in-blockchain";

const ADDRESS_PATTERN = "\[ADDRESS\]";

const ADDRESSES_TO_CONTENTS = [
  {
    address: SITE_NAME,
    content: "<!DOCTYPE html>\n" +
        "<html>\n" +
        "<head>\n" +
        "        <meta charset=\"utf-8\">\n" +
        "        <title>Simple site in blockchain</title>\n" +
        "        <meta name=\"description\" content=\"Simple site in blockchain demonstate storage reading\">\n" +
        "</head>\n" +
        "<body>\n" +
        "        This is first in the world site in simple blockchain storage!\n" +
        "</body>\n" +
        "</html>\n"
  }
];

const DOMAINS_TO_ADDRESSES = [
  {
    domain: "blockwit",
    address: "https://blockwit.io"
  },
  {
    domain: "bscscan",
    address: "https://bscscan.com"
  },
  {
    domain: "simple-site-in-blockchain",
    address: "bns.bsc.simple_storage_" + ADDRESS_PATTERN + "://" + SITE_NAME
  }
];

//bns.bsc.simple_storage_0x2Ad485e03e5A6846187f8eD12bd402458647f330://simple-site-in-blockchain

async function deploy () {
  const { log } = logger(await web3.eth.net.getNetworkType());
  const [deployer] = await web3.eth.getAccounts();

  const wallet = await Wallet.new({ from: deployer });
  log(`Wallet deployed: @address{${wallet.address}}`);

  const bnsSimpleStorage = await BNSSimpleStorage.new({ from: deployer });
  log(`BNSSimpleStorage deployed: @address{${bnsSimpleStorage.address}}`);

  DOMAINS_TO_ADDRESSES[2].address = DOMAINS_TO_ADDRESSES[2].address.replace(ADDRESS_PATTERN, bnsSimpleStorage.address);

  log(`BNSSimpleStorage. Add content for simple site ${ADDRESSES_TO_CONTENTS[0].address}.`);
  const tx1 = await bnsSimpleStorage.setContent(ADDRESSES_TO_CONTENTS[0].address, ADDRESSES_TO_CONTENTS[0].content, { from: deployer });
  log(`Result: successful tx: @tx{${tx1.receipt.transactionHash}}`);

  const bnsRepository = await BNSRepository.new({ from: deployer });
  log(`BNSRepository deployed: @address{${bnsRepository.address}}`);

  log(`BNSRepository. Add address ${DOMAINS_TO_ADDRESSES[0].address} for domain  ${DOMAINS_TO_ADDRESSES[0].domain} for 999 days.`);
  const latestTime = await time.latest();
  const tx2 = await bnsRepository.setDomainName(deployer, DOMAINS_TO_ADDRESSES[0].domain, DOMAINS_TO_ADDRESSES[0].address, latestTime, new BN(999), { from: deployer });
  log(`Result: successful tx2: @tx{${tx2.receipt.transactionHash}}`);
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
