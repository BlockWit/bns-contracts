// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./interfaces/IDividendPayingToken.sol";
import "./lib/Assets.sol";
import "./BNSNFT.sol";
import "./BNSMarketPricePolicy.sol";
import "./BNSNamesPolicy.sol";
import "./AssetHandler.sol";

contract BNSDomainNameMarket is Pausable, AccessControl, AssetHandler {

    BNSMarketPricePolicy public pricePolicy;
    BNSNamesPolicy public namesPolicy;
    BNSNFT public bnsnft;
    IDividendPayingToken public dividendManager;
    mapping (string => address) public domainBuyers;
    mapping (string => uint) public domainPrices;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setBNSNFT(address newBnsnft) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bnsnft = BNSNFT(newBnsnft);
    }

    function setDividendManager(address newDividendManager) public onlyRole(DEFAULT_ADMIN_ROLE) {
        dividendManager = IDividendPayingToken(newDividendManager);
    }

    function setPricePolicy(address newPricePolicy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        pricePolicy = BNSMarketPricePolicy(newPricePolicy);
    }

    function setNamesPolicy(address newNamesPolicy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        namesPolicy = BNSNamesPolicy(newNamesPolicy);
    }

    function setAsset(address key, string memory assetTicker, Assets.AssetType assetType) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _setAsset(key, assetTicker, assetType);
    }

    function removeAsset(address key) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _removeAsset(key);
    }

    function getPrice(string memory domainName, address assetKey) public view returns(uint) {
        // sanitize domain name and calculate price
        domainName = namesPolicy.perform(domainName);
        return getPriceForPerformedName(domainName, assetKey);
    }

    function getPriceForPerformedName(string memory domainName, address assetKey) private view returns(uint) {
        require(!bnsnft.domainNameExists(domainName), "Domain name already exists");
        namesPolicy.check(domainName);
        return pricePolicy.getPrice(domainName, assetKey);
    }

    function buy(string memory domainName, address assetKey) whenNotPaused external {
        // sanitize domain name and calculate price
        domainName = namesPolicy.perform(domainName);
        uint256 price = getPriceForPerformedName(domainName, assetKey);
        // charge payment
        _transferAssetFrom(msg.sender, address(this), price, assetKey);
        IERC20(assetKey).approve(address(dividendManager), price);
        dividendManager.distributeDividends(price, assetKey);
        // update statistics
        domainBuyers[domainName] = msg.sender;
        domainPrices[domainName] = price;
        // mint NFT
        bnsnft.safeMint(msg.sender, domainName);
    }

}
