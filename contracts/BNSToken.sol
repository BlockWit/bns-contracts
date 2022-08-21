// SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./DividendPayingToken.sol";

contract BNSToken is DividendPayingToken, AccessControl {
    constructor() payable ERC20("BNSToken", "BNST") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(msg.sender, 1000000 ether);
    }

    function setAsset(address key, string memory assetTicker, Assets.AssetType assetType) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _setAsset(key, assetTicker, assetType);
    }

    function removeAsset(address key) onlyRole(DEFAULT_ADMIN_ROLE) external returns (bool) {
        return _removeAsset(key);
    }
}
