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
    IDividendPayingToken public dividendsManager;
    mapping (string => address) public domainBuyers;
    mapping (string => uint) public domainPrices;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setBNSNFT(address newBnsnft) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bnsnft = BNSNFT(newBnsnft);
    }

    function setIDividendPayingToken(address newIDividendPayingToken) public onlyRole(DEFAULT_ADMIN_ROLE) {
        dividendsManager = IDividendPayingToken(newIDividendPayingToken);
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

    function getPrice(string memory domainName, string memory refererDomainName, address assetKey) private view returns(uint) {
        require(!bnsnft.domainNameExists(domainName), "Domain name already exists");

        if(bytes(refererDomainName).length == 0) {
            refererDomainName = namesPolicy.perform(refererDomainName);
            require(bnsnft.domainNameExists(refererDomainName), "Referer domain name must exists");
        }

        domainName = namesPolicy.perform(domainName);
        namesPolicy.check(domainName);
        return pricePolicy.getPrice(domainName, refererDomainName, assetKey);
    }

    function buy(string memory domainName, string memory refererDomainName, address assetKey) whenNotPaused external {
        uint refererTokenId;
        address refererAddress;
        if(bytes(refererDomainName).length == 0) {
            refererDomainName = namesPolicy.perform(refererDomainName);
            refererTokenId = bnsnft.getTokenIdByDomainName(refererDomainName);
            refererAddress = bnsnft.ownerOf(refererTokenId);
        }
        // sanitize domain name and calculate price
        domainName = namesPolicy.perform(domainName);
        require(!bnsnft.domainNameExists(domainName), "Domain name already exists");
        uint256 price = pricePolicy.getPrice(domainName, refererDomainName, assetKey);

        // charge payment
        _transferAssetFrom(msg.sender, address(this), price, assetKey);

        if(bytes(refererDomainName).length == 0) {
            IERC20(assetKey).transfer(address(dividendsManager), price);
        } else {
            // TODO must be dynamically declared
            uint toReferer = price*100/10;
            IERC20(assetKey).transfer(refererAddress, toReferer);
            IERC20(assetKey).transfer(address(dividendsManager), price - toReferer);
        }

        // update statistics
        domainBuyers[domainName] = msg.sender;
        domainPrices[domainName] = price;
        // mint NFT
        bnsnft.safeMint(msg.sender, domainName);
    }

}
