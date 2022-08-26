const { accounts, contract} = require('@openzeppelin/test-environment');
const { expectRevert, ether} = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const BNSMarketPricePolicy = contract.fromArtifact('BNSMarketPricePolicy');
const ERC20Mock = contract.fromArtifact('ERC20Mock');

const [account1, owner ] = accounts;

describe('BNSMarketPricePolicy', function () {
    let contract;
    let asset;
    const sizes = [1, 2, 3];
    const prices = [100, 200, 300];
    const sizes1 = [1, 2, 3];
    const prices1 = [100, 200];

    beforeEach(async function () {
        contract = await BNSMarketPricePolicy.new({from: owner});
        asset = await ERC20Mock.new('First Mock Token', 'FRST', owner, ether('10000'), { from: owner });
    });

    describe('getPriceForPremiumDomain', function () {
        context('if premiumDomainPrice is set', function () {
            it('should return price', async function () {
                await contract.unsafeSetPremiumDomainPrice('haha', 500, { from: owner });
                const price = await contract.getPriceForPremiumDomain('haha');
                expect(price).to.be.bignumber.equal('500');
            });
        });
        context('if premiumDomainPrice is not set', function () {
            it('revert', async function () {
                await expectRevert(contract.getPriceForPremiumDomain('haha'),
                    "Domain not in premium list");
            });
        });
    });

    describe('getPrice', function () {
        context('when premiumDomainPrice is set ', function () {
            context('if hasReferer == false ', function () {
                it('should return price', async function () {
                    await contract.unsafeSetPremiumDomainPrice('haha', 500, { from: owner });
                    expect(await contract.getPrice("haha", asset.address, false)).to.be.bignumber.equal("500");
                });
            });
            context('if hasReferer == true ', function () {
                it('should return price with discount', async function () {
                    const discount = [1, 2, 1664478000];
                    await contract.setDiscount(0, discount, { from: owner });
                    expect(await contract.discounts[0]).to.be.equal(discount);
                    await contract.unsafeSetPremiumDomainPrice('haha', 500, { from: owner });
                    expect(await contract.getPrice("haha", asset.address, true)).to.be.bignumber.equal("500");
                });
            });
        });
        context('when premiumDomainPrice is not set', function () {
            context('if pricePerNameLength is set', function () {
                it('should return pricePerNameLength', async function () {
                    await contract.setDefaultPrice(300, {from : owner});
                    expect(await contract.getPrice("HaHaHaHaH", )).to.be.bignumber.equal("300");
                });
            });
            context('if pricePerNameLength is not set', function () {
                it('should return defaultPrice', async function () {
                    await contract.setDefaultPrice(300, {from : owner});
                    expect(await contract.getPrice("HaHaHaHaH", )).to.be.bignumber.equal("300");
                });
            });
            context('if hasReferer is true', function () {
                it('should return discounted price', async function () {
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
