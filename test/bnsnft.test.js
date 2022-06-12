const {
  accounts,
  contract
} = require('@openzeppelin/test-environment');
const {
  BN
} = require('@openzeppelin/test-helpers');
const {expect} = require('chai');

const BNSNFT = contract.fromArtifact('BNSNFT');

const [account1, account2, owner] = accounts;

const DOMAINS_TO_DATA = [
  {
    domain: "blockwit",
    address: new BN(0),
    content: "Some content of blockwit site"
  },
  {
    domain: "mysite",
    address: new BN(0),
    content: "Some content of mysyte"
  }
];

const ONE_DAY = new BN(1);

describe('BNSRepository', async () => {
  let bnsnft;

  beforeEach(async function () {
    bnsnft = await BNSNFT.new({ from: owner });
  });

  describe('Check set and get domain data', function () {
    it('Check set and get single domain name', async function () {
      const receipt = await bnsnft.safeMint(account1, DOMAINS_TO_DATA[0].domain, { from: owner });
      const tokenId = receipt.logs[0].args.tokenId.valueOf();
      DOMAINS_TO_DATA[0].address = tokenId;
      const addressTokenId = await bnsnft.getTokenIdByDomainName(DOMAINS_TO_DATA[0].domain);
      await bnsnft.setContent(tokenId, DOMAINS_TO_DATA[0].content, { from: owner });
      expect(await bnsnft.getContent(addressTokenId)).to.be.equal(DOMAINS_TO_DATA[0].content);
    });
  });

});
