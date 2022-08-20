// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/Assets.sol";

contract AssetHandler {

    using Assets for Assets.Map;

    Assets.Map assets;

    function _setAsset(uint256 key, string memory assetTicker, Assets.AssetType assetType, address assetAddress) internal virtual returns (bool) {
        return assets.set(key, Assets.Asset(assetTicker, assetType, assetAddress));
    }

    function _removeAsset(uint256 key) internal virtual returns (bool) {
        return assets.remove(key);
    }

    function assetsLength() public view returns (uint256) {
        return assets.length();
    }

    function getAssetAt(uint256 index) public view returns (uint256, Assets.Asset memory) {
        return assets.at(index);
    }

    function getAsset(uint256 key) public view returns (Assets.Asset memory) {
        return assets.get(key);
    }

    function _transferAsset(address sender, address recipient, uint256 amount, uint256 assetId) internal {
        Assets.Asset memory asset = assets.get(assetId);
        IERC20(asset.assetAddress).transferFrom(sender, recipient, amount);
    }

}
