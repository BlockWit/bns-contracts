const {
  accounts,
  contract,
} = require('@openzeppelin/test-environment');
const {
  time, BN
} = require('@openzeppelin/test-helpers');
const {expect} = require("chai");

const BNSSimpleStorage = contract.fromArtifact('BNSSimpleStorage');
const BNSRepository = contract.fromArtifact('BNSRepository');

const [account1, owner] = accounts;

const ADDRESS_PATTERN = "\[ADDRESS\]";

const ONE_DAY = new BN(1);

const SITE_NAME = "simple-site-in-blockchain";

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

describe('BNSRepository with BNSSimpleStorage integration', async () => {
  let bnsRepository;
  let bnsSimpleStorage;

  beforeEach(async function () {
    bnsSimpleStorage = await BNSSimpleStorage.new({ from: owner });
    DOMAINS_TO_ADDRESSES[2].address = DOMAINS_TO_ADDRESSES[2].address.replace(ADDRESS_PATTERN, bnsSimpleStorage.address);
    await bnsSimpleStorage.setContent(SITE_NAME, ADDRESSES_TO_CONTENTS[0].content, {from: owner});

    bnsRepository = await BNSRepository.new({ from: owner });
    const latestTime = await time.latest();
    await bnsRepository.setDomainName(account1, DOMAINS_TO_ADDRESSES[2].domain, DOMAINS_TO_ADDRESSES[2].address, latestTime, ONE_DAY, {from: owner});
  });

  describe('Full flow', function () {
    it('Check getting single site content by domain', async function () {
      const siteContentAddress = await bnsRepository.getAddressForDomainName(DOMAINS_TO_ADDRESSES[2].domain);
      let result = siteContentAddress.match(/bns.bsc.simple_storage_(0x[\da-fA-F]{40}):\/\/(.*)/);
      const bnsSimpleStorageFromAddress = new BNSSimpleStorage(result[1]);
      expect(await bnsSimpleStorageFromAddress.getContent(result[2])).to.be.equal(ADDRESSES_TO_CONTENTS[0].content);
    });
  });

});
