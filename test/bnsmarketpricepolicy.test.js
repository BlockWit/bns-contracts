const { accounts, contract} = require('@openzeppelin/test-environment');
const { expectRevert, ether} = require('@openzeppelin/test-helpers');
const { expect } = require('chai');
const {timestamp} = require("truffle/build/6062.bundled");

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
    const discounts = [['1', '2', '1693415398'],['3', '4' ,'1693415398'],['9', '10', '1693415398']];
    const domainNames = ['block', 'site', 'lol'];
    const UTF8_RANGES = [
        ['0x00004E00', '0x000062FF'],
        ['0x00006300', '0x000077FF'],
        ['0x00000600', '0x000006FF']
    ]

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
                    await contract.setDiscount(discounts, { from: owner });
                    await contract.unsafeSetPremiumDomainPrice('haha', 500, { from: owner });
                    expect(await contract.getPrice("haha", asset.address, true)).to.be.bignumber.equal("250");
                });
            });
        });
        context('when premiumDomainPrice is not set', function () {
            context('if pricePerNameLength is set', function () {
                it('should return pricePerNameLength', async function () {
                    await contract.setPrice(4, 300, {from : owner});
                    expect(await contract.getPrice("haha", asset.address, false)).to.be.bignumber.equal("300");
                });
            });
            context('if pricePerNameLength is not set', function () {
                it('should return defaultPrice', async function () {
                    await contract.setDefaultPrice(300, {from : owner});
                    expect(await contract.getPrice("haha", asset.address, false)).to.be.bignumber.equal("300");
                });
            });
            context('if hasReferer is true', function () {
                it('should return discounted price', async function () {
                    await contract.setPrice(4, 300, {from : owner});
                    await contract.setDiscount(discounts, { from: owner });
                    expect(await contract.getPrice("haha", asset.address, true)).to.be.bignumber.equal("150");
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

    describe('setDiscount', function () {
        context('when called by owner', function () {
            context('if discounts was empty', function () {
                it('should add new discounts', async function () {
                    await contract.setDiscount(discounts, {from : owner});
                    const temp = await contract.discounts(2);
                    expect(temp[0]).to.be.bignumber.equal(discounts[2][0]);
                    expect(temp[1]).to.be.bignumber.equal(discounts[2][1]);
                    expect(temp[2]).to.be.bignumber.equal(discounts[2][2]);
                });
            });
            context('if amount of new and old discounts are equal', function () {
                it('should change discounts', async function () {
                    const oldDiscounts = [['2', '3', '1664289293'],['4', '5' ,'1664289293'],['19', '20', '1664289293']];
                    await contract.setDiscount(oldDiscounts, {from : owner});
                    await contract.setDiscount(discounts, {from : owner});
                    const temp = await contract.discounts(2);
                    expect(temp[0]).to.be.bignumber.equal(discounts[2][0]);
                    expect(temp[1]).to.be.bignumber.equal(discounts[2][1]);
                    expect(temp[2]).to.be.bignumber.equal(discounts[2][2]);
                });
            });
            context('if amount of old discounts > new discounts', function () {
                it('should change discounts and trim array', async function () {
                    const oldDiscounts = [['2', '3', '1664289293'],['4', '5' ,'1664289293'],['19', '20', '1664289293'], ['29', '30', '1664289293']];
                    await contract.setDiscount(oldDiscounts, {from : owner});
                    await contract.setDiscount(discounts, {from : owner});
                    const temp = await contract.discounts(2);
                    expect(temp[0]).to.be.bignumber.equal(discounts[2][0]);
                    expect(temp[1]).to.be.bignumber.equal(discounts[2][1]);
                    expect(temp[2]).to.be.bignumber.equal(discounts[2][2]);
                    await expectRevert.unspecified(contract.discounts(3));
                });
            });
            context('if amount of old discounts < new discounts', function () {
                it('should add all new discounts', async function () {
                    const oldDiscounts = [['2', '3', '1664289293'],['4', '5' ,'1664289293']];
                    await contract.setDiscount(oldDiscounts, {from : owner});
                    await contract.setDiscount(discounts, {from : owner});
                    const temp = await contract.discounts(2);
                    expect(temp[0]).to.be.bignumber.equal(discounts[2][0]);
                    expect(temp[1]).to.be.bignumber.equal(discounts[2][1]);
                    expect(temp[2]).to.be.bignumber.equal(discounts[2][2]);
                });
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await expectRevert.unspecified(contract.setDiscount(discounts, {from : account1}));
            });
        });
    });

    describe('calculateDiscount', function () {
        context('if there are valid discounts', function () {
            it('should return discount', async function () {
                await contract.setDiscount(discounts, {from : owner});
                const temp = await contract.discounts(2);
                expect(temp[0]).to.be.bignumber.equal(discounts[2][0]);
                expect(temp[1]).to.be.bignumber.equal(discounts[2][1]);
                expect(temp[2]).to.be.bignumber.equal(discounts[2][2]);
                expect(await contract.calculateDiscount(1000, 1661880372)).to.be.bignumber.equal('500');
            });
        });
        context('if no valid discounts', function () {
            it('should return 0', async function () {
                expect(await contract.calculateDiscount(1000, 1661880372)).to.be.bignumber.equal('0');
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

    describe('setPriceForSymbolsWithinRange', function () {
        context('when called by owner', function () {
            it('should change pricePerNameLengthForSymbolsWithinRange', async function () {
                await contract.setPriceForSymbolsWithinRange(10, 212, {from : owner});
                expect(await contract.pricePerNameLengthForSymbolsWithinRange(10)).to.be.bignumber.equal("212");
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await expectRevert(contract.setPriceForSymbolsWithinRange(5, 2222, {from : account1}),
                    "Ownable: caller is not the owner");
            });
        });
    });

    describe('addUTF8Ranges', function () {
        context('when called by owner', function () {
            it('should add utf8ranges to array', async function () {
                await contract.addUTF8Ranges(UTF8_RANGES, {from : owner});
                let temp = await contract.utf8ranges(0);
                expect(await temp[0]).to.be.equal('0x00004e00');
                expect(await temp[1]).to.be.equal('0x000062ff');
                temp = await contract.utf8ranges(1);
                expect(await temp[0]).to.be.equal('0x00006300');
                expect(await temp[1]).to.be.equal('0x000077ff');
                temp = await contract.utf8ranges(2);
                expect(await temp[0]).to.be.equal('0x00000600');
                expect(await temp[1]).to.be.equal('0x000006ff');
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await expectRevert(contract.addUTF8Ranges(UTF8_RANGES, {from : account1}),
                    "Ownable: caller is not the owner");
            });
        });
    });

    describe('removeUTF8Range', function () {
        context('when called by owner', function () {
            it('should delete range at specified index', async function () {
                await contract.addUTF8Ranges(UTF8_RANGES, {from : owner});

                await contract.removeUTF8Range(0, {from : owner});
                let temp = await contract.utf8ranges(0);
                expect(await temp[0]).to.be.equal('0x00006300');
                expect(await temp[1]).to.be.equal('0x000077ff');
                temp = await contract.utf8ranges(1);
                expect(await temp[0]).to.be.equal('0x00000600');
                expect(await temp[1]).to.be.equal('0x000006ff');
                await expectRevert.unspecified(contract.utf8ranges(2));

                await contract.removeUTF8Range(1, {from : owner});
                temp = await contract.utf8ranges(0);
                expect(await temp[0]).to.be.equal('0x00006300');
                expect(await temp[1]).to.be.equal('0x000077ff');
                await expectRevert.unspecified(contract.utf8ranges(1));
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await contract.addUTF8Ranges(UTF8_RANGES, {from : owner});
                await expectRevert(contract.removeUTF8Range(0, {from : account1}),
                    "Ownable: caller is not the owner");
            });
        });
    });

    describe('setUTF8Range', function () {
        context('when called by owner', function () {
            it('should change range at specified index', async function () {
                await contract.addUTF8Ranges(UTF8_RANGES, {from : owner});
                let temp = await contract.utf8ranges(1);
                expect(await temp[0]).to.be.equal('0x00006300');
                expect(await temp[1]).to.be.equal('0x000077ff');

                await contract.setUTF8Range('0x00000600', '0x000006ff', 1, {from : owner});
                temp = await contract.utf8ranges(1);
                expect(await temp[0]).to.be.equal('0x00000600');
                expect(await temp[1]).to.be.equal('0x000006ff');
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await contract.addUTF8Ranges(UTF8_RANGES, {from : owner});
                await expectRevert(contract.setUTF8Range('0x00000600', '0x000006ff', 1, {from : account1}),
                    "Ownable: caller is not the owner");
            });
        });
    });

    describe('unsafeSetPremiumDomainPrices', function () {
        context('when called by owner', function () {
            context('if domainNames.length == prices.length', function () {
                it('should change premiumDomainPrices', async function () {
                    await contract.unsafeSetPremiumDomainPrices(domainNames, prices, { from: owner });
                    expect(await contract.getPrice("block", asset.address, false)).to.be.bignumber.equal('100');
                    expect(await contract.getPrice("site", asset.address, false)).to.be.bignumber.equal('200');
                    expect(await contract.getPrice("lol", asset.address, false)).to.be.bignumber.equal('300');
                });
            });
            context('if domainNames.length != prices.length', function () {
                it('revert', async function () {
                    await expectRevert(contract.unsafeSetPremiumDomainPrices(domainNames, prices1, { from: owner }),
                        "Count of domain names and prices must be equals!");
                });
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await expectRevert(contract.unsafeSetPremiumDomainPrices(domainNames, prices, { from: account1 }),
                    "Ownable: caller is not the owner");
            });
        });
    });

    describe('unsafeSetPremiumDomainPrice', function () {
        context('when called by owner', function () {
            it('should set premiumDomainPrices', async function () {
                await contract.unsafeSetPremiumDomainPrice('haha', 500, { from: owner });
                expect(await contract.getPrice("haha", asset.address, false)).to.be.bignumber.equal("500");
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

    describe('setPricesForSymbolsWithinRange', function () {
        context('when called by owner', function () {
            context('if sizes.length == prices.length', function () {
                it('should change defaultPriceForSymbolsWithinRange and pricePerNameLengthForSymbolsWithinRange', async function () {
                    await contract.setPricesForSymbolsWithinRange(1111, sizes, prices, {from: owner});
                    expect(await contract.defaultPriceForSymbolsWithinRange()).to.be.bignumber.equal("1111");
                    expect(await contract.pricePerNameLengthForSymbolsWithinRange(1)).to.be.bignumber.equal("100");
                    expect(await contract.pricePerNameLengthForSymbolsWithinRange(2)).to.be.bignumber.equal("200");
                    expect(await contract.pricePerNameLengthForSymbolsWithinRange(3)).to.be.bignumber.equal("300");
                });
            });
            context('if sizes.length != prices.length', function () {
                it('revert', async function () {
                    await expectRevert(contract.setPricesForSymbolsWithinRange(2222, sizes1, prices1, {from : owner}),
                        "Size and price arrays must have the same length");
                });
            });
        });
        context('when called not by owner', function () {
            it('revert', async function () {
                await expectRevert(contract.setPricesForSymbolsWithinRange(2222, sizes, prices, {from : account1}),
                    "Ownable: caller is not the owner");
            });
        });
    });

    describe('isWithinRange', function () {
        context('if domainName`s first symbol in range', function () {
            it('return true ', async function () {
                await contract.addUTF8Ranges(UTF8_RANGES, {from : owner});
                expect(await contract.isWithinRange('ۿ')).to.be.equal(true);
            });
        });
        context('if domainName`s first symbol not in range', function () {
            it('return false', async function () {
                await contract.addUTF8Ranges(UTF8_RANGES, {from : owner});
                expect(await contract.isWithinRange('hah')).to.be.equal(false);
            });
        });
    });
});
