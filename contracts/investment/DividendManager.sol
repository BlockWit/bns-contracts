// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../interfaces/IDividendManager.sol";
import "../lib/SafeMath.sol";
import "../AssetHandler.sol";
import "./BookKeeper.sol";


contract DividendManager is IDividendManager, BookKeeper, AssetHandler, AccessControl {

    using SafeMath for uint256;
    using SafeMath for int256;

    uint256 constant internal MAGNITUDE = 2**128;
    mapping(Assets.Key => uint256) internal magnifiedDividendPerShare;
    mapping(Assets.Key => mapping(AccountId => int256)) internal magnifiedDividendCorrections;
    mapping(Assets.Key => mapping(AccountId => uint256)) internal withdrawnDividends;
    IERC721 public nft;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setNFT(address newNFT) external onlyRole(DEFAULT_ADMIN_ROLE) {
        nft = IERC721(newNFT);
    }

    function withdrawDividend(AccountId account) override public {
        for (uint256 i = 0; i < assetsLength(); i++) {
            (Assets.Key assetKey, ) = getAssetAt(i);
            withdrawDividend(account, assetKey);
        }
    }

    function dividendOf(AccountId account) override public view returns(Dividend[] memory) {
        Dividend[] memory dividends;
        for (uint256 i = 0; i < assetsLength(); i++) {
            (Assets.Key assetKey, Assets.Asset memory asset) = getAssetAt(i);
            dividends[i] = Dividend(assetKey, asset.assetTicker, dividendOf(account, assetKey));
        }
        return dividends;
    }

    function withdrawableDividendOf(AccountId account) override public view returns(Dividend[] memory) {
        Dividend[] memory dividends;
        for (uint256 i = 0; i < assetsLength(); i++) {
            (Assets.Key assetKey, Assets.Asset memory asset) = getAssetAt(i);
            dividends[i] = Dividend(assetKey, asset.assetTicker, withdrawableDividendOf(account, assetKey));
        }
        return dividends;
    }

    function withdrawnDividendOf(AccountId account) override public view returns(Dividend[] memory) {
        Dividend[] memory dividends;
        for (uint256 i = 0; i < assetsLength(); i++) {
            (Assets.Key assetKey, Assets.Asset memory asset) = getAssetAt(i);
            dividends[i] = Dividend(assetKey, asset.assetTicker, withdrawnDividendOf(account, assetKey));
        }
        return dividends;
    }

    function accumulativeDividendOf(AccountId account) override public view returns(Dividend[] memory) {
        Dividend[] memory dividends;
        for (uint256 i = 0; i < assetsLength(); i++) {
            (Assets.Key assetKey, Assets.Asset memory asset) = getAssetAt(i);
            dividends[i] = Dividend(assetKey, asset.assetTicker, accumulativeDividendOf(account, assetKey));
        }
        return dividends;
    }

    function distributeDividends(uint256 amount, Assets.Key assetKey) public {
        require(totalSupply() > 0, "DividendManager: totalSupply must be greater than 0");
        require(amount > 0, "DividendManager: amount must be greater than 0");
        _transferAssetFrom(msg.sender, address(this), amount, assetKey);
        magnifiedDividendPerShare[assetKey] = magnifiedDividendPerShare[assetKey] + (amount * MAGNITUDE / totalSupply());
        emit DividendsDistributed(msg.sender, amount, assetKey);
    }

    function withdrawDividend(AccountId account, Assets.Key assetKey) public {
        uint256 _withdrawableDividend = withdrawableDividendOf(account, assetKey);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[assetKey][account] = withdrawnDividends[assetKey][account] + _withdrawableDividend;
            emit DividendWithdrawn(account, _withdrawableDividend, assetKey);
            _transferAsset(nft.ownerOf(AccountId.unwrap(account)), _withdrawableDividend, assetKey);
        }
    }

    function dividendOf(AccountId _owner, Assets.Key assetKey) public view returns(uint256) {
        return withdrawableDividendOf(_owner, assetKey);
    }

    function withdrawableDividendOf(AccountId _owner, Assets.Key assetKey) public view returns(uint256) {
        return accumulativeDividendOf(_owner, assetKey) - withdrawnDividends[assetKey][_owner];
    }

    function withdrawnDividendOf(AccountId _owner, Assets.Key assetKey) public view returns(uint256) {
        return withdrawnDividends[assetKey][_owner];
    }

    function accumulativeDividendOf(AccountId _owner, Assets.Key assetKey) public view returns(uint256) {
        return ((magnifiedDividendPerShare[assetKey] * balanceOf(AccountId.unwrap(_owner))).toInt256Safe() + magnifiedDividendCorrections[assetKey][_owner]).toUint256Safe() / MAGNITUDE;
    }

    function mint(AccountId account, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _mint(AccountId.unwrap(account), amount);
    }

    function burn(AccountId account, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _burn(AccountId.unwrap(account), amount);
    }

    function _mint(AccountId account, uint256 amount) internal {
        super._mint(AccountId.unwrap(account), amount);
        for (uint256 i = 0; i < assetsLength(); i++) {
            (Assets.Key assetKey, ) = getAssetAt(i);
            magnifiedDividendCorrections[assetKey][account] = magnifiedDividendCorrections[assetKey][account] - (magnifiedDividendPerShare[assetKey] * amount).toInt256Safe();
        }
    }

    function _burn(AccountId account, uint256 value) internal {
        super._burn(AccountId.unwrap(account), value);
        for (uint256 i = 0; i < assetsLength(); i++) {
            (Assets.Key assetKey, ) = getAssetAt(i);
            magnifiedDividendCorrections[assetKey][account] = magnifiedDividendCorrections[assetKey][account] + (magnifiedDividendPerShare[assetKey] * value).toInt256Safe();
        }
    }
}
