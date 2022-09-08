// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/Assets.sol";
import "./lib/StringUtils.sol";
import "./lib/UTF8Utils.sol";
import "./DiscountCalculator.sol";
import "./RecoverableFunds.sol";

contract BNSMarketPricePolicy is Ownable, DiscountCalculator, RecoverableFunds {

    struct UTF8Range {
        bytes4 first;
        bytes4 last;
    }

    using StringUtils for string;

    mapping (uint => uint) public pricePerNameLength;
    mapping (uint => uint) public pricePerNameLengthForSymbolsWithinRange;
    mapping (bytes32 => uint) public premiumDomainPrices;
    UTF8Range[] public utf8ranges;
    uint public defaultPrice;
    uint public defaultPriceForSymbolsWithinRange;

    function getPriceForPremiumDomain(string memory domainName) external view returns(uint) {
        uint price = premiumDomainPrices[keccak256(abi.encodePacked(domainName))];
        require(price > 0, "Domain not in premium list");
        return price;
    }

    function getPrice(string memory domainName, Assets.Key assetKey, bool hasReferer) external view returns(uint) {
        uint256 price = premiumDomainPrices[keccak256(abi.encodePacked(domainName))];
        if (price == 0 && isWithinRange(domainName)) {
            price = pricePerNameLengthForSymbolsWithinRange[domainName.length()];
            if (price == 0) {
                price = defaultPriceForSymbolsWithinRange;
            }
        }
        if (price == 0) {
            price = pricePerNameLength[domainName.length()];
        }
        if (price == 0) {
            price = defaultPrice;
        }
        if (hasReferer) {
            price = price - calculateDiscount(price, block.timestamp);
        }
        return price;
    }

    function setDefaultPrice(uint price) public onlyOwner {
        defaultPrice = price;
    }

    function setDefaultPriceForSymbolsWithinRange(uint price) public onlyOwner {
        defaultPriceForSymbolsWithinRange = price;
    }

    function setDiscount(Discount[] calldata discounts) external onlyOwner {
        _setDiscount(discounts);
    }

    function setPrice(uint size, uint price) public onlyOwner {
        pricePerNameLength[size] = price;
    }

    function setPriceForSymbolsWithinRange(uint size, uint price) public onlyOwner {
        pricePerNameLengthForSymbolsWithinRange[size] = price;
    }

    function addUTF8Range(bytes4 first, bytes4 last) external onlyOwner {
        utf8ranges.push(UTF8Range(first, last));
    }

    function removeUTF8Range(uint256 index) external onlyOwner {
        for (uint256 i = index; i < utf8ranges.length - 1; i++) {
            utf8ranges[i] = utf8ranges[i + 1];
        }
        utf8ranges.pop();
    }

    function setUTF8Range(bytes4 first, bytes4 last, uint256 index) external onlyOwner {
        utf8ranges[index] = UTF8Range(first, last);
    }

    /**
    * Domain names must be sanitized prior to calling this method
    **/
    function unsafeSetPremiumDomainPrices(string[] memory domainNames, uint[] memory prices) public onlyOwner {
        require(domainNames.length == prices.length, "Count of domain names and prices must be equals!");
        for(uint i = 0; i < domainNames.length; i++) {
           premiumDomainPrices[keccak256(abi.encodePacked(domainNames[i]))] = prices[i];
        }
    }

    /**
    * Domain name must be sanitized prior to calling this method
    **/
    function unsafeSetPremiumDomainPrice(string memory domainName, uint price) public onlyOwner {
       premiumDomainPrices[keccak256(abi.encodePacked(domainName))] = price;
    }

    function setPrices(uint newDefaultPrice, uint[] memory sizes, uint[] memory prices) public onlyOwner {
        require(sizes.length == prices.length, "Count of sizes and prices must be equals!");
        defaultPrice = newDefaultPrice;
        for(uint i = 0; i<sizes.length; i++) {
            pricePerNameLength[sizes[i]] = prices[i];
        }
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyOwner {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyOwner {
        _retrieveETH(recipient);
    }

    function isWithinRange(string memory domainName) public view returns (bool) {
        bytes4 firstCharCode = UTF8Utils.getCharCodeAt(domainName, 0);
        for (uint256 i; i < utf8ranges.length; i++) {
            UTF8Range memory range = utf8ranges[i];
            if (firstCharCode >= range.first && firstCharCode <= range.last) return true;
        }
        return false;
    }

}
