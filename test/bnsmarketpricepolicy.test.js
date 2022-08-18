const { accounts, contract} = require('@openzeppelin/test-environment');
const { expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

const BNSMarketPricePolicy = contract.fromArtifact('BNSMarketPricePolicy');

const [account1, owner ] = accounts;

describe('BNSMarketPricePolicy', function () {
    let contract;
    let tokenId = 1;
    const sizes = [1, 2, 3];
    const prices = [100, 200, 300];
    const sizes1 = [1, 2, 3];
    const prices1 = [100, 200];

    beforeEach(async function () {
        contract = await BNSMarketPricePolicy.new({from: owner});
    });

    describe('setDefaultPrice', function () {
        it('should change defaultPrice if called by owner', async function () {
            await contract.setDefaultPrice(1337, {from : owner});
            expect(await contract.defaultPrice()).to.be.bignumber.equal("1337");
        });

        it('should throw an error if called not by owner', async function () {
            await expectRevert.unspecified(contract.setDefaultPrice(1337, {from : account1}));
        });
    });

    describe('setPrice', function () {
        it('should change pricePerNameLength if called by owner', async function () {
            await contract.setPrice(2, 111, {from : owner});
            expect(await contract.pricePerNameLength(2)).to.be.bignumber.equal("111");
        });

        it('should throw an error if called not by owner', async function () {
            await expectRevert(contract.setPrice(5, 2222, {from : account1}),
                "Ownable: caller is not the owner");
        });
    });

    describe('setPrices', function () {
        it('should change defaultPrice and pricePerNameLength if called by owner', async function () {
            await contract.setPrices(1111, sizes, prices, {from: owner});
            expect(await contract.defaultPrice()).to.be.bignumber.equal("1111");
            expect(await contract.pricePerNameLength(1)).to.be.bignumber.equal("100");
            expect(await contract.pricePerNameLength(2)).to.be.bignumber.equal("200");
            expect(await contract.pricePerNameLength(3)).to.be.bignumber.equal("300");
        });

        it('should throw an error if called not by owner', async function () {
            await expectRevert(contract.setPrices(2222, sizes, prices, {from : account1}),
                "Ownable: caller is not the owner");
        });

        it('should throw an error if sizes.length != prices.length', async function () {
            await expectRevert(contract.setPrices(2222, sizes1, prices1, {from : owner}),
                "Count of sizes and prices must be equals!");
        });
    });

    describe('getPrice', function () {
        it('should return price for domainName', async function () {
            await contract.setPrice(5, 500, {from : owner});
            expect(await contract.getPrice("HaHaH", tokenId)).to.be.bignumber.equal("500");
        });

        it('should return defaultPrice if pricePerNameLength is not set', async function () {
            await contract.setDefaultPrice(300, {from : owner});
            expect(await contract.getPrice("HaHaHaHaH", tokenId)).to.be.bignumber.equal("300");
        });
    });
});
