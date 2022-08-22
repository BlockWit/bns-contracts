const { accounts, contract} = require('@openzeppelin/test-environment');
const { expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const BNSMarketPricePolicy = contract.fromArtifact('BNSMarketPricePolicy');

const [account1, owner ] = accounts;

describe('BNSMarketPricePolicy', function () {
    let contract;
    const sizes = [1, 2, 3];
    const prices = [100, 200, 300];
    const sizes1 = [1, 2, 3];
    const prices1 = [100, 200];

    beforeEach(async function () {
        contract = await BNSMarketPricePolicy.new({from: owner});
    });

    //waiting for assetKey logic to complete test
    describe('getPrice', function () {
        context('when pricePerNameLength is set ', function () {
            it('should return price', async function () {
                await contract.setPrice(5, 500, {from : owner});
                expect(await contract.getPrice("HaHaH", )).to.be.bignumber.equal("500");
            });
        });
        context('when pricePerNameLength is not set', function () {
            context('if defaultPrice is set', function () {
                it('should return defaultPrice', async function () {
                    await contract.setDefaultPrice(300, {from : owner});
                    expect(await contract.getPrice("HaHaHaHaH", )).to.be.bignumber.equal("300");
                });
            });
            context('if defaultPrice is not set', function () {
                it('should return 0', async function () {
                    expect(await contract.getPrice("HaHaHaHaH", )).to.be.bignumber.equal("0");
                });
            });
        });
    });

    describe('setDefaultPrice', function () {
        context('when called by owner', function () {
            it('should change defaultPrice', async function () {
                await contract.setDefaultPrice(1337, {from : owner});
                expect(await contract.defaultPrice()).to.be.bignumber.equal("1337");
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await expectRevert.unspecified(contract.setDefaultPrice(1337, {from : account1}));
            });
        });
    });

    describe('setPrice', function () {
        context('when called by owner', function () {
            it('should change pricePerNameLength', async function () {
                await contract.setPrice(2, 111, {from : owner});
                expect(await contract.pricePerNameLength(2)).to.be.bignumber.equal("111");
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await expectRevert(contract.setPrice(5, 2222, {from : account1}),
                    "Ownable: caller is not the owner");
            });
        });
    });

    describe('setPrices', function () {
        context('when called by owner', function () {
            context('if sizes.length == prices.length', function () {
                it('should change defaultPrice and pricePerNameLength', async function () {
                    await contract.setPrices(1111, sizes, prices, {from: owner});
                    expect(await contract.defaultPrice()).to.be.bignumber.equal("1111");
                    expect(await contract.pricePerNameLength(1)).to.be.bignumber.equal("100");
                    expect(await contract.pricePerNameLength(2)).to.be.bignumber.equal("200");
                    expect(await contract.pricePerNameLength(3)).to.be.bignumber.equal("300");
                });
            });
            context('if sizes.length != prices.length', function () {
                it('revert', async function () {
                    await expectRevert(contract.setPrices(2222, sizes1, prices1, {from : owner}),
                        "Count of sizes and prices must be equals!");
                });
            });
            });
        context('when called not by owner', function () {
            it('revert', async function () {
                await expectRevert(contract.setPrices(2222, sizes, prices, {from : account1}),
                    "Ownable: caller is not the owner");
            });
        });
    });
});
