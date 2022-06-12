const {
  accounts,
  contract
} = require('@openzeppelin/test-environment');
const {
  expectRevert,
} = require('@openzeppelin/test-helpers');

const {expect} = require('chai');

const BNSSimpleStorage = contract.fromArtifact('BNSSimpleStorage');

const [account1, owner] = accounts;

const ADDRESSES_TO_CONTENTS = [
  {
    address: "simple-site-in-blockchain",
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

describe('BNSSimpleStorage', async () => {
  let bnsSimpleStorage;

  beforeEach(async function () {
    bnsSimpleStorage = await BNSSimpleStorage.new({ from: owner });
  });

  describe('Check only owner functions throws corresponding exception', function () {
    it('setContent', async function () {
      await expectRevert(bnsSimpleStorage.setContent(ADDRESSES_TO_CONTENTS[0].address, ADDRESSES_TO_CONTENTS[0].content, {from: account1}),
        'Ownable: caller is not the owner'
      );
    });
  });

  describe('Check set and get domain names', function () {
    it('Check set and get single domain name', async function () {
      await bnsSimpleStorage.setContent(ADDRESSES_TO_CONTENTS[0].address, ADDRESSES_TO_CONTENTS[0].content, {from: owner});
      expect(await bnsSimpleStorage.getContent(ADDRESSES_TO_CONTENTS[0].address)).to.be.equal(ADDRESSES_TO_CONTENTS[0].content);
    });
  });

});
