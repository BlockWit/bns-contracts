// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./interfaces/IDividendManager.sol";
import "./lib/Assets.sol";
import "./BNSNFT.sol";
import "./AssetHandler.sol";

contract BNSDomainNameMarket is Pausable, AccessControl, AssetHandler, RecoverableFunds {

    BNSNFT public bnsnft;
    IDividendManager public dividendManager;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setBNSNFT(address newBnsnft) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bnsnft = BNSNFT(newBnsnft);
    }

    function setDividendManager(address newDividendManager) public onlyRole(DEFAULT_ADMIN_ROLE) {
        dividendManager = IDividendManager(newDividendManager);
    }

    function setAsset(Assets.Key key, string memory assetTicker, Assets.AssetType assetType) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _setAsset(key, assetTicker, assetType);
    }

    function removeAsset(Assets.Key key) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _removeAsset(key);
    }

    function buy(string[] memory domainNames, uint price, address buyer, address referer, uint refererBonus, Assets.Key assetKey, bool flag) whenNotPaused external onlyRole(MINTER_ROLE) {
        if (price != 0) {
            // charge payment
            if (flag == false) {
                _transferAssetFrom(buyer, address(this), price, assetKey);
            }

            uint dividends = price;
            if (refererBonus > 0) {
                dividends = dividends - refererBonus;
                _transferAsset(referer, refererBonus, assetKey);
            }
            _approveAsset(address(dividendManager), dividends, assetKey);
            dividendManager.distributeDividends(price - refererBonus, assetKey);
        }

        // mint all NFT
        bnsnft.safeBatchMint(buyer, domainNames);
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveETH(recipient);
    }

}
