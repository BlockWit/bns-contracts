const { accounts, contract} = require('@openzeppelin/test-environment');
const { expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const BNSNamesPolicy = contract.fromArtifact('BNSNamesPolicy');

const [account1, owner ] = accounts;

describe('BNSNamesPolicy', function () {
    let contract;

    beforeEach(async function () {
        contract = await BNSNamesPolicy.new({from: owner});
    });

    describe('setForbiddenSymbols', function () {
        it('should change forbiddenSymbols if called by admin', async function () {
            await contract.setForbiddenSymbols(",|*", {from : owner});
            expect(await contract.forbiddenSymbols()).to.be.equal(",|*");
        });

        it('should throw an error if called not by admin', async function () {
            await expectRevert.unspecified(contract.setForbiddenSymbols("| *", {from: account1}));
        });
    });

    describe('perform', function () {
        let contract;

        beforeEach(async function () {
            contract = await BNSNamesPolicy.new({from: owner});
        });

        it('should change domainName to lowercase', async function () {
            expect(await contract.perform("HaHaHa")).to.be.equal("hahaha");
        });
    });

    describe('check', function () {
        let contract;

        beforeEach(async function () {
            contract = await BNSNamesPolicy.new({from: owner});
        });

        it('should work if domainName is not empty and doesn`t contain forbiddenSymbols', async function () {
            expect(await contract.check("haHaha"));
        });

        it('should throw an error if forbiddenSymbols was changed and domainName contains it', async function () {
            await contract.setForbiddenSymbols(",", {from : owner});
            await expectRevert(contract.check("ha,ha"), "Domain name contains forbidden symbol");
        });

        it('should throw an error if domainName is empty', async function () {
            await expectRevert(contract.check(""), "Domain name should not be empty!");
        });

        it('should throw an error if domainName contains forbiddenSymbols', async function () {
            await expectRevert(contract.check("ha*ha"), "Domain name contains forbidden symbol");
        });
    });
});
