// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../AssetHandler.sol";

contract AssetHandlerMock is AssetHandler {

    function setAsset(address key, string memory assetTicker, Assets.AssetType assetType) external returns (bool) {
        return _setAsset(key, assetTicker, assetType);
    }

    function removeAsset(address key) external returns (bool) {
        return _removeAsset(key);
    }

    function transfer(address sender, address recipient, uint256 amount, address assetKey) external {
        return _transferAsset(sender, recipient, amount, assetKey);
    }

}
