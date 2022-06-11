const {
  accounts,
  contract
} = require('@openzeppelin/test-environment');
const {
  BN,
  expectRevert,
  time
} = require('@openzeppelin/test-helpers');
const {expect} = require('chai');

const BNSRepository = contract.fromArtifact('BNSRepository');

const [account1, account2, owner] = accounts;

const SITE_DOMAIN_NOT_FOUND = "not_found_domain_name";

const DOMAINS_TO_ADDRESSES = [
  {
    domain: "blockwit",
    address: "https://blockwit.io"
  },
  {
    domain: "bscscan",
    address: "https://bscscan.com"
  }
];

const ONE_DAY = new BN(1);

describe('BNSRepository', async () => {
  let bnsRepo;

  beforeEach(async function () {
    bnsRepo = await BNSRepository.new({ from: owner });
  });

  describe('Check only owner functions throws corresponding exception', function () {
    it('setDomainName', async function () {
      const latestTime = await time.latest();
      await expectRevert(bnsRepo.setDomainName(account2, DOMAINS_TO_ADDRESSES[0].domain, DOMAINS_TO_ADDRESSES[0].address, latestTime, ONE_DAY, {from: account1}),
        'Ownable: caller is not the owner'
      );
    });
  });

  describe('Check set and get domain names', function () {
    it('Check set and get single domain name', async function () {
      const latestTime = await time.latest();
      await bnsRepo.setDomainName(account2, DOMAINS_TO_ADDRESSES[0].domain, DOMAINS_TO_ADDRESSES[0].address, latestTime, ONE_DAY, {from: owner});
      expect(await bnsRepo.getAddressForDomainName(DOMAINS_TO_ADDRESSES[0].domain)).to.be.equal(DOMAINS_TO_ADDRESSES[0].address);
    });
    it('Check get single empty domain name returns error', async function () {
      await expectRevert(bnsRepo.getAddressForDomainName(SITE_DOMAIN_NOT_FOUND),
          'Requested name record not found!'
      );
    });
    it('Check set and get multiple domain names', async function () {
      const latestTime = await time.latest();
      for(let i=0; i<DOMAINS_TO_ADDRESSES.length; i++) {
        await bnsRepo.setDomainName(account2, DOMAINS_TO_ADDRESSES[i].domain, DOMAINS_TO_ADDRESSES[i].address, latestTime, ONE_DAY, {from: owner});
      }
      for(let i=0; i<DOMAINS_TO_ADDRESSES.length; i++) {
        expect(await bnsRepo.getAddressForDomainName(DOMAINS_TO_ADDRESSES[i].domain)).to.be.equal(DOMAINS_TO_ADDRESSES[i].address);
      }
    });
  });

});
