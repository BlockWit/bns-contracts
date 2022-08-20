// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./DividendPayingToken.sol";

contract BNSToken is DividendPayingToken, AccessControl {
    constructor(address initialAccount, uint256 initialBalance) payable ERC20("BNSToken", "BNST") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(initialAccount, initialBalance);
    }

    function setAsset(address key, string memory assetTicker, Assets.AssetType assetType) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _setAsset(key, assetTicker, assetType);
    }

    function removeAsset(address key) onlyRole(DEFAULT_ADMIN_ROLE) external returns (bool) {
        return _removeAsset(key);
    }
}