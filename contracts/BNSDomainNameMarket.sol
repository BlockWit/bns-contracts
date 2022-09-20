// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./interfaces/IDividendManager.sol";
import "./lib/Assets.sol";
import "./BNSNFT.sol";
import "./BNSMarketPricePolicy.sol";
import "./BNSNamesPolicy.sol";
import "./AssetHandler.sol";

contract BNSDomainNameMarket is Pausable, AccessControl, AssetHandler, RecoverableFunds {

    BNSMarketPricePolicy public pricePolicy;
    BNSNamesPolicy public namesPolicy;
    BNSNFT public bnsnft;
    IDividendManager public dividendManager;
    uint256 public refererBonusNumerator = 10;
    uint256 public refererBonusDenominator = 100;

    struct DomainInfo {
        string name;
        uint256 fullPrice;
        uint256 discountedPrice;
        bool isAvailable;
        address owner;
}

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setBNSNFT(address newBnsnft) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bnsnft = BNSNFT(newBnsnft);
    }

    function setDividendManager(address newDividendManager) public onlyRole(DEFAULT_ADMIN_ROLE) {
        dividendManager = IDividendManager(newDividendManager);
    }

    function setPricePolicy(address newPricePolicy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        pricePolicy = BNSMarketPricePolicy(newPricePolicy);
    }

    function setNamesPolicy(address newNamesPolicy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        namesPolicy = BNSNamesPolicy(newNamesPolicy);
    }

    function setAsset(Assets.Key key, string memory assetTicker, Assets.AssetType assetType) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _setAsset(key, assetTicker, assetType);
    }

    function setRefererBonus(uint256 numerator, uint256 denominator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        refererBonusNumerator = numerator;
        refererBonusDenominator = denominator;
    }

    function removeAsset(Assets.Key key) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _removeAsset(key);
    }

    function getPriceWithoutReferer(string memory domainName, Assets.Key assetKey) public view returns(uint) {
        return getPrice(domainName, "", assetKey);
    }

    function getPrice(string memory domainName, string memory refererDomainName, Assets.Key assetKey) public view returns(uint) {
        require(!bnsnft.isDomainNameExists(domainName), "Domain name already exists");

        if (bytes(refererDomainName).length > 0) {
            refererDomainName = namesPolicy.perform(refererDomainName);
            require(bnsnft.isDomainNameExists(refererDomainName), "Referer domain name must exists");
        }

        domainName = namesPolicy.perform(domainName);
        namesPolicy.check(domainName);
        return pricePolicy.getPrice(domainName, assetKey, bytes(refererDomainName).length > 0);
    }

    function getDomainInfo(string[] calldata domainNames, string memory refererDomainName, Assets.Key assetKey) external view returns (DomainInfo[] memory) {
        DomainInfo[] memory domainsInfo;
        DomainInfo memory domainInfo;

        if (bytes(refererDomainName).length > 0) {
            refererDomainName = namesPolicy.perform(refererDomainName);
            require(bnsnft.isDomainNameExists(refererDomainName), "Referer domain name must exists");
        }

        for(uint i = 0; i < domainNames.length; i++ ) {
            string memory domainName = domainNames[i];
            domainName = namesPolicy.perform(domainName);
            namesPolicy.check(domainName);

            //set name
            domainInfo.name = domainName;

            //set isAvailable and owner
            if (bnsnft.isDomainNameExists(domainName)) {
                domainInfo.isAvailable = false;
                domainInfo.owner = bnsnft.ownerOf(bnsnft.getTokenIdByDomainName(domainName));
            } else {
                domainInfo.isAvailable = true;
            }

            //set fullPrice and discountedPrice
            if (bytes(refererDomainName).length > 0) {
                domainInfo.fullPrice = pricePolicy.getPrice(domainName, assetKey, false);
                domainInfo.discountedPrice = pricePolicy.getPrice(domainName, assetKey, true);
            } else {
                domainInfo.fullPrice = pricePolicy.getPrice(domainName, assetKey, false);
                domainInfo.discountedPrice = domainInfo.fullPrice;
            }

            domainsInfo[i].push(domainInfo);
        }

        return domainsInfo;
    }


    function buyWithoutReferer(string memory domainName, Assets.Key assetKey) external {
        domainName = namesPolicy.perform(domainName);
        namesPolicy.check(domainName);
        require(!bnsnft.isDomainNameExists(domainName), "Domain name already exists");
        uint256 price = pricePolicy.getPrice(domainName, assetKey, false);

        // charge payment
        _transferAssetFrom(msg.sender, address(this), price, assetKey);

        _approveAsset(address(dividendManager), price, assetKey);
        dividendManager.distributeDividends(price, assetKey);

        // mint NFT
        bnsnft.safeMint(msg.sender, domainName);
    }

    function buy(string memory domainName, string memory refererDomainName, Assets.Key assetKey) whenNotPaused external {
        uint refererTokenId;
        address refererAddress;
        bool hasReferer;
        if (bytes(refererDomainName).length > 0) {
            refererDomainName = namesPolicy.perform(refererDomainName);
            refererTokenId = bnsnft.getTokenIdByDomainName(refererDomainName);
            refererAddress = bnsnft.ownerOf(refererTokenId);
            hasReferer = true;
        }
        // sanitize domain name and calculate price
        domainName = namesPolicy.perform(domainName);
        namesPolicy.check(domainName);
        require(!bnsnft.isDomainNameExists(domainName), "Domain name already exists");
        uint256 price = pricePolicy.getPrice(domainName, assetKey, hasReferer);

        // charge payment
        _transferAssetFrom(msg.sender, address(this), price, assetKey);

        uint256 refererBonus;
        uint256 dividends = price;
        if (hasReferer) {
            refererBonus = refererBonusDenominator > 0 ? price * refererBonusNumerator / refererBonusDenominator : 0;
        }
        if (refererBonus > 0) {
            dividends = dividends - refererBonus;
            _transferAsset(refererAddress, refererBonus, assetKey);
        }
        _approveAsset(address(dividendManager), dividends, assetKey);
        dividendManager.distributeDividends(price - refererBonus, assetKey);

        // mint NFT
        bnsnft.safeMint(msg.sender, domainName);
    }

    function buyBulk(string[] memory domainNames, string memory refererDomainName, Assets.Key assetKey) whenNotPaused external {
        uint refererTokenId;
        address refererAddress;
        bool hasReferer;
        if (bytes(refererDomainName).length > 0) {
            refererDomainName = namesPolicy.perform(refererDomainName);
            refererTokenId = bnsnft.getTokenIdByDomainName(refererDomainName);
            refererAddress = bnsnft.ownerOf(refererTokenId);
            hasReferer = true;
        }

        // sanitize domain names and calculate overall price
        uint256 price = 0;
        for(uint i = 0; i < domainNames.length; i++ ) {
            domainNames[i] = namesPolicy.perform(domainNames[i]);
            namesPolicy.check(domainNames[i]);
            require(!bnsnft.isDomainNameExists(domainNames[i]), "Domain name already exists");
            price = price + pricePolicy.getPrice(domainNames[i], assetKey, hasReferer);
        }

        // charge payment
        _transferAssetFrom(msg.sender, address(this), price, assetKey);

        uint256 refererBonus;
        uint256 dividends = price;
        if (hasReferer) {
            refererBonus = refererBonusDenominator > 0 ? price * refererBonusNumerator / refererBonusDenominator : 0;
        }
        if (refererBonus > 0) {
            dividends = dividends - refererBonus;
            _transferAsset(refererAddress, refererBonus, assetKey);
        }
        _approveAsset(address(dividendManager), dividends, assetKey);
        dividendManager.distributeDividends(price - refererBonus, assetKey);

        // mint all NFT
        bnsnft.safeBatchMint(msg.sender, domainNames);
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveETH(recipient);
    }

}
