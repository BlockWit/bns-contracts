const { accounts, contract, web3 } = require('@openzeppelin/test-environment');
const { balance, BN, constants, ether, expectEvent, expectRevert, time } = require('@openzeppelin/test-helpers');
const { assert, expect } = require('chai');

const BNSToken = contract.fromArtifact('BNSToken');
const ERC20Mock = contract.fromArtifact('ERC20Mock');

const [ deployer, holder1, holder2, user ] = accounts;
const totalAmount = ether('1000');
const holder1share = 70;
const holder2share = 30;

describe('BNSToken', function () {
  let token;
  let busd;
  let usdt;

  beforeEach(async function () {
    [ token, busd, usdt ] = await Promise.all([
      BNSToken.new(deployer, totalAmount, { from: deployer }),
      ERC20Mock.new('BUSD Pegged Token', 'BUSD', user, ether('20000'), { from: deployer }),
      ERC20Mock.new('USDT Pegged Token', 'USDT', user, ether('30000'), { from: deployer })
    ])
    await Promise.all([
      token.transfer(holder1, totalAmount.muln(holder1share).divn(100), { from: deployer }),
      token.transfer(holder2, totalAmount.muln(holder2share).divn(100), { from: deployer }),
      token.setAsset(busd.address, 'BUSD', 1, { from: deployer }),
      token.setAsset(usdt.address, 'USDT', 1, { from: deployer }),
    ]);
  });

  describe('withdrawDividend', function () {
    it('should correctly calculate and send amount to the holder', async function () {
      const busdAmount = ether('123');
      const usdtAmount = ether('456');
      await busd.approve(token.address, busdAmount, { from: user });
      await usdt.approve(token.address, usdtAmount, { from: user });

      await token.distributeDividends(busdAmount, busd.address, { from: user });
      await token.distributeDividends(usdtAmount, usdt.address, { from: user });
      await token.withdrawDividend({ from: holder1 });
      await token.withdrawDividend({ from: holder2 });
      {
        const busdBalance = await busd.balanceOf(holder1);
        const usdtBalance = await usdt.balanceOf(holder1);
        approxEqual(busdBalance, busdAmount.muln(holder1share).divn(100), 1);
        approxEqual(usdtBalance, usdtAmount.muln(holder1share).divn(100), 1);
      }
      {
        const busdBalance = await busd.balanceOf(holder2);
        const usdtBalance = await usdt.balanceOf(holder2);
        approxEqual(busdBalance, busdAmount.muln(holder2share).divn(100), 1);
        approxEqual(usdtBalance, usdtAmount.muln(holder2share).divn(100), 1);
      }
    });
  });
});

function approxEqual(bn, target, deviation) {
  if (typeof deviation === 'number') deviation = new BN(deviation.toString());
  expect(bn).to.be.bignumber.gte(target.sub(deviation)).and.lte(target.add(deviation));
}
