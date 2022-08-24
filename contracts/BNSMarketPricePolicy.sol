// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/StringUtils.sol";
import "./DiscountCalculator.sol";
import "./RecoverableFunds.sol";

contract BNSMarketPricePolicy is Ownable, DiscountCalculator, RecoverableFunds {

    using StringUtils for string;

    mapping (uint => uint) public pricePerNameLength;

    mapping (bytes32 => uint) public premiumDomainPrices;

    uint public defaultPrice;

    function getPriceForPremiumDomain(string memory domainName) public view returns(uint) {
        uint price = premiumDomainPrices[keccak256(abi.encodePacked(domainName))];
        require(price > 0, "Domain not in premium list");
        return price;
    }

    function getPrice(string memory domainName, address assetKey, bool hasReferer) public view returns(uint) {
        uint price = premiumDomainPrices[keccak256(abi.encodePacked(domainName))];
        if(price == 0) {
            price = pricePerNameLength[domainName.length()];
            if(price == 0) price = defaultPrice;
        }
        if (hasReferer) {
            price = price - calculateDiscount(price, block.timestamp);
        }
        return price;
    }

    function setDefaultPrice(uint price) public onlyOwner {
        defaultPrice = price;
    }

    function setDiscount(uint256 index, Discount calldata discount) external onlyOwner {
        _setDiscount(index, discount);
    }

    function setPrice(uint size, uint price) public onlyOwner {
        pricePerNameLength[size] = price;
    }

    /**
    *
    * Domain names should performed before fill
    *
    **/
    function unsafeSetPremiumDomainPrices(string[] memory domainNames, uint[] memory prices) public onlyOwner {
        require(domainNames.length == prices.length, "Count of domain names and prices must be equals!");
        for(uint i = 0; i < domainNames.length; i++) {
           premiumDomainPrices[keccak256(abi.encodePacked(domainNames[i]))] = prices[i];
        }
    }

    /**
    *
    * Domain names should performed before fill
    *
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

}
