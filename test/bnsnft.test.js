const {accounts, contract, web3} = require('@openzeppelin/test-environment');
const {BN, expectRevert, ether} = require('@openzeppelin/test-helpers');
const {expect} = require('chai');
const {getEvents} = require("./util");

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
const domainNames = ['blockwit', 'mysite', 'lol'];

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

  describe('unsafeBatchMint', function () {
    context('when called by admin', function () {
      it('should add domains in array to specified address', async function () {
        expect(await bnsnft.balanceOf(account1, { from: account1})).to.be.bignumber.equal('0');
        await bnsnft.unsafeBatchMint(account1, domainNames, { from: owner});
        expect(await bnsnft.balanceOf(account1, { from: account1})).to.be.bignumber.equal('3');
      });
    });
    context('when called by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(bnsnft.unsafeBatchMint(account1, domainNames, { from: account1}));
      });
    });
  });

  describe('safeBatchMint', function () {
    context('when called by admin', function () {
      it('should mint domains in array to specified address', async function () {
        expect(await bnsnft.balanceOf(account2, { from: account2})).to.be.bignumber.equal('0');
        await bnsnft.safeBatchMint(account2, domainNames, { from: owner});
        expect(await bnsnft.balanceOf(account2, { from: account2})).to.be.bignumber.equal('3');
      });
    });
    context('when called by admin', function () {
      it('revert', async function () {
        await expectRevert.unspecified(bnsnft.safeBatchMint(account1, domainNames, { from: account1}));
      });
    });
  });

});
