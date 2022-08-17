const { accounts, contract} = require('@openzeppelin/test-environment');
const { expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const BNSNamesPolicy = contract.fromArtifact('BNSNamesPolicy');

const [account1, owner ] = accounts;

describe('test setForbiddenSymbols', function () {
    let contract;

    beforeEach(async function () {
        contract = await BNSNamesPolicy.new({from: owner});
    });

    it('forbiddenSymbols check', async function () {
        expect(await contract.forbiddenSymbols()).to.be.equal(".*/ ");
    });

    it('admin(owner) can change forbiddenSymbols', async function () {
        await contract.setForbiddenSymbols(",|*", {from : owner});
        expect(await contract.forbiddenSymbols()).to.be.equal(",|*");
    });

    it('not admin can`t change forbiddenSymbols', async function () {
        await expectRevert.unspecified(contract.setForbiddenSymbols("| *", {from: account1}));
    });
});

describe('test perform', function () {
    let contract;

    beforeEach(async function () {
        contract = await BNSNamesPolicy.new({from: owner});
    });

    it('changing to lowercase', async function () {
        expect(await contract.perform("HaHaHa")).to.be.equal("hahaha");
    });
});

describe('test check', function () {
    let contract;

    beforeEach(async function () {
        contract = await BNSNamesPolicy.new({from: owner});
    });

    it('working', async function () {
        expect(await contract.check("haHaha"));
    });

    it('if domainName is empty -> error', async function () {
        await expectRevert(contract.check(""), "Domain name should not be empty!");
    });

    it('if domainName contains forbidden symbol -> error', async function () {
        await expectRevert(contract.check("ha*ha"), "Domain name contains forbidden symbol");
    });
});