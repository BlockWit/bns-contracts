// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../AssetHandler.sol";

contract AssetHandlerMock is AssetHandler {

    function setAsset(uint256 key, string memory assetTicker, Assets.AssetType assetType, address assetAddress) external returns (bool) {
        return _setAsset(key, assetTicker, assetType, assetAddress);
    }

    function removeAsset(uint256 key) external returns (bool) {
        return _removeAsset(key);
    }

    function transfer(address sender, address recipient, uint256 amount, uint256 currencyId) external {
        return _transferAsset(sender, recipient, amount, currencyId);
    }

}
