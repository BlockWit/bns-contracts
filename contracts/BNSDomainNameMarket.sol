// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./BNSNFT.sol";
import "./BNSMarketPricePolicy.sol";
import "./BNSNamesPolicy.sol";
import "./lib/Assets.sol";
import "./AssetHandler.sol";

contract BNSDomainNameMarket is Pausable, AccessControl, AssetHandler {

    BNSMarketPricePolicy public pricePolicy;
    BNSNamesPolicy public namesPolicy;
    BNSNFT public bnsnft;
    address public fundraisingWallet;
    mapping (string => address) public domainBuyers;
    mapping (string => uint) public domainPrices;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setBNSNFT(address newBnsnft) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bnsnft = BNSNFT(newBnsnft);
    }

    function setFundraisingWallet(address newFundraisingWallet) public onlyRole(DEFAULT_ADMIN_ROLE) {
        fundraisingWallet = newFundraisingWallet;
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

    function removeAsset(address key) external returns (bool) {
        return _removeAsset(key);
    }

    function buy(string memory domainName, address assetKey) whenNotPaused external {
        // sanitize domain name and calculate price
        domainName = namesPolicy.perform(domainName);
        namesPolicy.check(domainName);
        require(!bnsnft.isDomainNameExists(domainName), "Domain name already exists");
        uint256 price = pricePolicy.getPrice(domainName, assetKey);
        // charge payment
        _transferAsset(msg.sender, fundraisingWallet, price, assetKey);
        // update statistics
        domainBuyers[domainName] = msg.sender;
        domainPrices[domainName] = price;
        // mint NFT
        bnsnft.safeMint(msg.sender, domainName);
    }

}
