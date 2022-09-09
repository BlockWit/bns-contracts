const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');
const { getEvents } = require('./util');

const BNSDomainNameMarket = contract.fromArtifact('BNSDomainNameMarket');
const BNSMarketPricePolicy = contract.fromArtifact('BNSMarketPricePolicy');
const BNSNamesPolicy = contract.fromArtifact('BNSNamesPolicy');
const BNSNFT = contract.fromArtifact('BNSNFT');
const DividendManager = contract.fromArtifact('DividendManager');
const ERC20Mock = contract.fromArtifact('ERC20Mock');

const SIZES = [1,2,3,4,5,6,7,8,9,10,11];
const PRICES_USDT = [100000,95000,90000,85000,75000,70000,65000,60000,55000,50000,45000];
const BASE_PRICE_USDT = 100;

const [ deployer, user, account1 ] = accounts;

describe('Gas', function () {
    let market;
    let names;
    let bnsnft;
    let pricing;
    let dividend;
    let tokens = {usdt: {id: 1, contract: undefined, key: 12345}, busd: {id: 2, contract: undefined, key: 23456}};

    beforeEach(async function () {
        [market, names, bnsnft, dividend, pricing, tokens.busd.contract, tokens.usdt.contract] = await Promise.all([
            BNSDomainNameMarket.new({from: deployer}),
            BNSNamesPolicy.new({from: deployer}),
            BNSNFT.new({from: deployer}),
            DividendManager.new({from: deployer}),
            BNSMarketPricePolicy.new({from: deployer}),
            ERC20Mock.new('BUSD Mock Token', 'BUSD', deployer, ether('100000000'), {from: deployer}),
            ERC20Mock.new('USDT Mock Token', 'USDT', deployer, ether('100000000'), {from: deployer}),
        ]);
        await Promise.all([
            tokens.busd.contract.transfer(user, ether('5000000'), {from: deployer}),
            tokens.usdt.contract.transfer(user, ether('5000000'), {from: deployer}),
            tokens.busd.contract.transfer(account1, ether('5000000'), {from: deployer}),
            tokens.usdt.contract.transfer(account1, ether('5000000'), {from: deployer})
        ])
    });

    describe('buy', function () {
        beforeEach(async function () {
            await Promise.all([
                bnsnft.grantRole(web3.utils.keccak256('MINTER_ROLE'), market.address, { from: deployer }),
                market.setDividendManager(dividend.address, { from: deployer }),
                market.setBNSNFT(bnsnft.address, { from: deployer }),
                market.setPricePolicy(pricing.address, { from: deployer }),
                market.setNamesPolicy(names.address, { from: deployer}),
                market.setAsset(tokens.usdt.contract.address, 'USDT', 1, {from : deployer}),
                market.setAsset(tokens.busd.contract.address, 'BUSD', 1, {from : deployer}),
                dividend.setAsset(tokens.usdt.contract.address, 'USDT', 1, {from : deployer}),
                dividend.setAsset(tokens.busd.contract.address, 'BUSD', 1, {from : deployer}),
                pricing.setPrices(ether(BASE_PRICE_USDT.toString()), SIZES, PRICES_USDT.map(price => ether(price.toString())), { from: deployer }),
                tokens.usdt.contract.approve(market.address, ether('250000'), { from: user }),
                tokens.usdt.contract.approve(market.address, ether('250000'), { from: account1 })
            ])
        });
        context('no referer', function () {
            it('gas', async function () {
                const tx = await market.buy('OneTwoThree', '', tokens.usdt.contract.address, { from: user });
                console.log(tx.receipt.gasUsed);
            });
        });
        context('with referer', function () {
            it('gas', async function () {
                await market.buy('OneTwo', '', tokens.usdt.contract.address, { from: account1 });
                const tx = await market.buy('OneTwoThree', 'OneTwo', tokens.usdt.contract.address, { from: user });
                console.log(tx.receipt.gasUsed);
            });
        });
    });

    describe('safeMint', function () {
        context('when called by admin', function () {
            it('gas', async function () {
                const tx = await bnsnft.safeMint(user, "OneTwoThree", { from: deployer });
                console.log(tx.receipt.gasUsed);
            });
        });
    });
});