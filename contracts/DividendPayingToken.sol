// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./interfaces/IDividendPayingToken.sol";
import "./lib/SafeMath.sol";
import "./AssetHandler.sol";


abstract contract DividendPayingToken is IDividendPayingToken, ERC20Burnable, AssetHandler {
  using SafeMath for uint256;
  using SafeMath for int256;

  uint256 constant internal MAGNITUDE = 2**128;
  mapping(uint256 => uint256) internal magnifiedDividendPerShare;
  mapping(uint256 => mapping(address => int256)) internal magnifiedDividendCorrections;
  mapping(uint256 => mapping(address => uint256)) internal withdrawnDividends;

  function distributeDividends() override public payable {
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, ) = getAssetAt(i);
      distributeDividends(assetId);
    }
  }

  function withdrawDividend() override public {
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, ) = getAssetAt(i);
      withdrawDividend(assetId);
    }
  }

  function dividendOf(address _owner) override public view returns(Dividend[] memory) {
    Dividend[] memory dividends;
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, Assets.Asset memory asset) = getAssetAt(i);
      dividends[i] = Dividend(asset.assetTicker, dividendOf(_owner, assetId));
    }
    return dividends;
  }

  function withdrawableDividendOf(address _owner) override public view returns(Dividend[] memory) {
    Dividend[] memory dividends;
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, Assets.Asset memory asset) = getAssetAt(i);
      dividends[i] = Dividend(asset.assetTicker, withdrawableDividendOf(_owner, assetId));
    }
    return dividends;
  }

  function withdrawnDividendOf(address _owner) override public view returns(Dividend[] memory) {
    Dividend[] memory dividends;
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, Assets.Asset memory asset) = getAssetAt(i);
      dividends[i] = Dividend(asset.assetTicker, withdrawnDividendOf(_owner, assetId));
    }
    return dividends;
  }

  function accumulativeDividendOf(address _owner) override public view returns(Dividend[] memory) {
    Dividend[] memory dividends;
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, Assets.Asset memory asset) = getAssetAt(i);
      dividends[i] = Dividend(asset.assetTicker, accumulativeDividendOf(_owner, assetId));
    }
    return dividends;
  }

  function distributeDividends(uint256 assetId) public payable {
    require(totalSupply() > 0);
    if (msg.value > 0) {
      magnifiedDividendPerShare[assetId] = magnifiedDividendPerShare[assetId] + (msg.value * MAGNITUDE / totalSupply());
      emit DividendsDistributed(msg.sender, msg.value, assetId);
    }
  }

  function withdrawDividend(uint256 assetId) public {
    uint256 _withdrawableDividend = withdrawableDividendOf(msg.sender, assetId);
    if (_withdrawableDividend > 0) {
      withdrawnDividends[assetId][msg.sender] = withdrawnDividends[assetId][msg.sender] + _withdrawableDividend;
      emit DividendWithdrawn(msg.sender, _withdrawableDividend, assetId);
      _transferAsset(address(this), msg.sender, _withdrawableDividend, assetId);
    }
  }

  function dividendOf(address _owner, uint256 assetId) public view returns(uint256) {
    return withdrawableDividendOf(_owner, assetId);
  }

  function withdrawableDividendOf(address _owner, uint256 assetId) public view returns(uint256) {
    return accumulativeDividendOf(_owner, assetId) - withdrawnDividends[assetId][_owner];
  }

  function withdrawnDividendOf(address _owner, uint256 assetId) public view returns(uint256) {
    return withdrawnDividends[assetId][_owner];
  }

  function accumulativeDividendOf(address _owner, uint256 assetId) public view returns(uint256) {
    return ((magnifiedDividendPerShare[assetId] * balanceOf(_owner)).toInt256Safe() + magnifiedDividendCorrections[assetId][_owner]).toUint256Safe() / MAGNITUDE;
  }

  function _transfer(address from, address to, uint256 value) override internal {
    super._transfer(from, to, value);
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, ) = getAssetAt(i);
      int256 _magCorrection = (magnifiedDividendPerShare[assetId] * value).toInt256Safe();
      magnifiedDividendCorrections[assetId][from] = magnifiedDividendCorrections[assetId][from] + _magCorrection;
      magnifiedDividendCorrections[assetId][to] = magnifiedDividendCorrections[assetId][to] - _magCorrection;
    }
  }

  function _mint(address account, uint256 value) override internal {
    super._mint(account, value);
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, ) = getAssetAt(i);
      magnifiedDividendCorrections[assetId][account] = magnifiedDividendCorrections[assetId][account] - (magnifiedDividendPerShare[assetId] * value).toInt256Safe();
    }
  }

  function _burn(address account, uint256 value) override internal {
    super._burn(account, value);
    for (uint256 i = 0; i < assetsLength(); i++) {
      (uint256 assetId, ) = getAssetAt(i);
      magnifiedDividendCorrections[assetId][account] = magnifiedDividendCorrections[assetId][account] + (magnifiedDividendPerShare[assetId] * value).toInt256Safe();
    }
  }
}
