// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IDividendPayingToken.sol";
import "./lib/SafeMath.sol";
import "./AssetHandler.sol";


abstract contract DividendPayingToken is IDividendPayingToken, ERC20Burnable, AssetHandler {
  using SafeMath for uint256;
  using SafeMath for int256;

  uint256 constant internal MAGNITUDE = 2**128;
  mapping(address => uint256) internal magnifiedDividendPerShare;
  mapping(address => mapping(address => int256)) internal magnifiedDividendCorrections;
  mapping(address => mapping(address => uint256)) internal withdrawnDividends;

  function withdrawDividend() override public {
    for (uint256 i = 0; i < assetsLength(); i++) {
      (address assetKey, ) = getAssetAt(i);
      withdrawDividend(assetKey);
    }
  }

  function dividendOf(address _owner) override public view returns(Dividend[] memory) {
    Dividend[] memory dividends;
    for (uint256 i = 0; i < assetsLength(); i++) {
      (address assetKey, Assets.Asset memory asset) = getAssetAt(i);
      dividends[i] = Dividend(assetKey, asset.assetTicker, dividendOf(_owner, assetKey));
    }
    return dividends;
  }

  function withdrawableDividendOf(address _owner) override public view returns(Dividend[] memory) {
    Dividend[] memory dividends;
    for (uint256 i = 0; i < assetsLength(); i++) {
      (address assetKey, Assets.Asset memory asset) = getAssetAt(i);
      dividends[i] = Dividend(assetKey, asset.assetTicker, withdrawableDividendOf(_owner, assetKey));
    }
    return dividends;
  }

  function withdrawnDividendOf(address _owner) override public view returns(Dividend[] memory) {
    Dividend[] memory dividends;
    for (uint256 i = 0; i < assetsLength(); i++) {
      (address assetKey, Assets.Asset memory asset) = getAssetAt(i);
      dividends[i] = Dividend(assetKey, asset.assetTicker, withdrawnDividendOf(_owner, assetKey));
    }
    return dividends;
  }

  function accumulativeDividendOf(address _owner) override public view returns(Dividend[] memory) {
    Dividend[] memory dividends;
    for (uint256 i = 0; i < assetsLength(); i++) {
      (address assetKey, Assets.Asset memory asset) = getAssetAt(i);
      dividends[i] = Dividend(assetKey, asset.assetTicker, accumulativeDividendOf(_owner, assetKey));
    }
    return dividends;
  }

  function distributeDividends(uint256 amount, address assetKey) public {
    require(totalSupply() > 0, "DividendPayingToken: totalSupply must be greater than 0");
    require(amount > 0, "DividendPayingToken: amount must be greater than 0");
    _transferAssetFrom(msg.sender, address(this), amount, assetKey);
    magnifiedDividendPerShare[assetKey] = magnifiedDividendPerShare[assetKey] + (amount * MAGNITUDE / totalSupply());
    emit DividendsDistributed(msg.sender, amount, assetKey);
  }

  function withdrawDividend(address assetKey) public {
    uint256 _withdrawableDividend = withdrawableDividendOf(msg.sender, assetKey);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[assetKey][msg.sender] = withdrawnDividends[assetKey][msg.sender] + _withdrawableDividend;
      emit DividendWithdrawn(msg.sender, _withdrawableDividend, assetKey);
      _transferAsset(msg.sender, _withdrawableDividend, assetKey);
    }
  }

  function dividendOf(address _owner, address assetKey) public view returns(uint256) {
    return withdrawableDividendOf(_owner, assetKey);
  }

  function withdrawableDividendOf(address _owner, address assetKey) public view returns(uint256) {
    return accumulativeDividendOf(_owner, assetKey) - withdrawnDividends[assetKey][_owner];
  }

  function withdrawnDividendOf(address _owner, address assetKey) public view returns(uint256) {
    return withdrawnDividends[assetKey][_owner];
  }

  function accumulativeDividendOf(address _owner, address assetKey) public view returns(uint256) {
    return ((magnifiedDividendPerShare[assetKey] * balanceOf(_owner)).toInt256Safe() + magnifiedDividendCorrections[assetKey][_owner]).toUint256Safe() / MAGNITUDE;
  }

  function _transfer(address from, address to, uint256 value) override internal {
    super._transfer(from, to, value);
    for (uint256 i = 0; i < assetsLength(); i++) {
      (address assetKey, ) = getAssetAt(i);
      int256 _magCorrection = (magnifiedDividendPerShare[assetKey] * value).toInt256Safe();
      magnifiedDividendCorrections[assetKey][from] = magnifiedDividendCorrections[assetKey][from] + _magCorrection;
      magnifiedDividendCorrections[assetKey][to] = magnifiedDividendCorrections[assetKey][to] - _magCorrection;
    }
  }

  function _mint(address account, uint256 value) override internal {
    super._mint(account, value);
    for (uint256 i = 0; i < assetsLength(); i++) {
      (address assetKey, ) = getAssetAt(i);
      magnifiedDividendCorrections[assetKey][account] = magnifiedDividendCorrections[assetKey][account] - (magnifiedDividendPerShare[assetKey] * value).toInt256Safe();
    }
  }

  function _burn(address account, uint256 value) override internal {
    super._burn(account, value);
    for (uint256 i = 0; i < assetsLength(); i++) {
      (address assetKey, ) = getAssetAt(i);
      magnifiedDividendCorrections[assetKey][account] = magnifiedDividendCorrections[assetKey][account] + (magnifiedDividendPerShare[assetKey] * value).toInt256Safe();
    }
  }
}
