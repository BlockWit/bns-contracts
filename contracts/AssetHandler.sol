// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/Assets.sol";

contract AssetHandler {

    using Assets for Assets.Map;

    Assets.Map assets;

    function _setAsset(address key, string memory assetTicker, Assets.AssetType assetType) internal virtual returns (bool) {
        return assets.set(key, Assets.Asset(assetTicker, assetType));
    }

    function _removeAsset(address key) internal virtual returns (bool) {
        return assets.remove(key);
    }

    function assetsLength() public view returns (uint256) {
        return assets.length();
    }

    function getAssetAt(uint256 index) public view returns (address, Assets.Asset memory) {
        return assets.at(index);
    }

    function getAsset(address key) public view returns (Assets.Asset memory) {
        return assets.get(key);
    }

    function _transferAsset(address recipient, uint256 amount, address assetKey) internal {
        Assets.Asset memory asset = assets.get(assetKey);
        require(asset.assetType == Assets.AssetType.ERC20, "AssetHandler: only ERC20 assets supported");
        IERC20(assetKey).transfer(recipient, amount);
    }

    function _transferAssetFrom(address sender, address recipient, uint256 amount, address assetKey) internal {
        Assets.Asset memory asset = assets.get(assetKey);
        require(asset.assetType == Assets.AssetType.ERC20, "AssetHandler: only ERC20 assets supported");
        IERC20(assetKey).transferFrom(sender, recipient, amount);
    }

}
