// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../AssetHandler.sol";

contract AssetHandlerMock is AssetHandler {

    function setAsset(uint256 key, address assetAddress, Assets.AssetType assetType) external returns (bool) {
        return _setAsset(key, assetAddress, assetType);
    }

    function removeAsset(uint256 key) external returns (bool) {
        return _removeAsset(key);
    }

    function transfer(address sender, address recipient, uint256 amount, uint256 currencyId) external {
        return _transfer(sender, recipient, amount, currencyId);
    }

}
