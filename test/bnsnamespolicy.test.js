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
        context('when called by admin', function () {
            it('should change forbiddenSymbols', async function () {
                await contract.setForbiddenSymbols(",|*", {from : owner});
                expect(await contract.forbiddenSymbols()).to.be.equal(",|*");
            });
        });
        context('when called not by admin', function () {
            it('revert', async function () {
                await expectRevert.unspecified(contract.setForbiddenSymbols("| *", {from: account1}));
            });
        });
    });

    describe('perform', function () {
        context('when domainName contains uppercase symbols', function () {
            it('should change to lowercase', async function () {
                expect(await contract.perform("HaHaHa")).to.be.equal("hahaha");
            });
        });
    });

    describe('check', function () {
        context('when domainName', function () {
            context('is not empty and doesn`t contain forbiddenSymbols', function () {
                it('should work', async function () {
                    expect(await contract.check("haHaha"));
                });
            });
            context('is empty', function () {
                it('revert', async function () {
                    await expectRevert(contract.check(""), "Domain name should not be empty!");
                });
            });
            context('contains forbiddenSymbols', function () {
                it('revert', async function () {
                    await expectRevert(contract.check("ha*ha"), "Domain name contains forbidden symbol");
                });
            });
        });
        context('when forbiddenSymbols were changed', function () {
            context('if domainName doesn`t contain forbiddenSymbols', function () {
                it('should work', async function () {
                    await contract.setForbiddenSymbols(",", {from : owner});
                    expect(await contract.check("haha"));
                });
            });
            context('if domainName contains forbiddenSymbols', function () {
                it('revert', async function () {
                    await contract.setForbiddenSymbols(",", {from : owner});
                    await expectRevert(contract.check("ha,ha"), "Domain name contains forbidden symbol");
                });
            });
        });
    });
});
