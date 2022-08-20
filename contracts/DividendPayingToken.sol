// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./interfaces/IDividendPayingToken.sol";
import "./lib/SafeMath.sol";


abstract contract DividendPayingToken is ERC20Burnable, IDividendPayingToken {
  using SafeMath for uint256;
  using SafeMath for int256;

  uint256 constant internal magnitude = 2**128;
  uint256 internal magnifiedDividendPerShare;
  mapping(address => int256) internal magnifiedDividendCorrections;
  mapping(address => uint256) internal withdrawnDividends;

  fallback() external payable {
    distributeDividends();
  }

  receive() external payable {
    distributeDividends();
  }

  function distributeDividends() override public payable {
    require(totalSupply() > 0);
    if (msg.value > 0) {
      magnifiedDividendPerShare = magnifiedDividendPerShare + (msg.value * magnitude / totalSupply());
      emit DividendsDistributed(msg.sender, msg.value);
    }
  }

  function withdrawDividend() override public {
    uint256 _withdrawableDividend = withdrawableDividendOf(msg.sender);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[msg.sender] = withdrawnDividends[msg.sender] + _withdrawableDividend;
      emit DividendWithdrawn(msg.sender, _withdrawableDividend);
      payable(msg.sender).transfer(_withdrawableDividend);
    }
  }

  function dividendOf(address _owner) override public view returns(uint256) {
    return withdrawableDividendOf(_owner);
  }

  function withdrawableDividendOf(address _owner) override public view returns(uint256) {
    return accumulativeDividendOf(_owner) - withdrawnDividends[_owner];
  }

  function withdrawnDividendOf(address _owner) override public view returns(uint256) {
    return withdrawnDividends[_owner];
  }

  function accumulativeDividendOf(address _owner) override public view returns(uint256) {
    return ((magnifiedDividendPerShare * balanceOf(_owner)).toInt256Safe() + magnifiedDividendCorrections[_owner]).toUint256Safe() / magnitude;
  }

  function _transfer(address from, address to, uint256 value) override internal {
    super._transfer(from, to, value);
    int256 _magCorrection = (magnifiedDividendPerShare * value).toInt256Safe();
    magnifiedDividendCorrections[from] = magnifiedDividendCorrections[from] + _magCorrection;
    magnifiedDividendCorrections[to] = magnifiedDividendCorrections[to] - _magCorrection;
  }

  function _mint(address account, uint256 value) override internal {
    super._mint(account, value);
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account] - (magnifiedDividendPerShare * value).toInt256Safe();
  }

  function _burn(address account, uint256 value) override internal {
    super._burn(account, value);
    magnifiedDividendCorrections[account] = magnifiedDividendCorrections[account] + (magnifiedDividendPerShare * value).toInt256Safe();
  }
}
