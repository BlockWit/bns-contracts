// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/StringUtils.sol";

contract BNSMarketPricePolicy is Ownable {

    using StringUtils for string;

    mapping (uint => uint) public pricePerNameLength;

    mapping (bytes32 => uint) public premiumDomainPrices;

    uint public defaultPrice;

    function getPriceForPremiumDomain(string memory domainName) public view returns(uint) {
        bytes32 hash = keccak256(abi.encodePacked(domainName));
        uint price = premiumDomainPrices[keccak256(abi.encodePacked(domainName))];
        require(price > 0, "Domain not in premium list");
        return price;
    }

    function getPrice(string memory domainName, string memory refererDomainName, address assetKey) public view returns(uint) {
        bytes32 hash = keccak256(abi.encodePacked(domainName));
        uint price = premiumDomainPrices[keccak256(abi.encodePacked(domainName))];
        if(price == 0) {
            uint price = pricePerNameLength[domainName.length()];
            if(price == 0) price = defaultPrice;
        }
        return price;
    }

    function setDefaultPrice(uint price) public onlyOwner {
        defaultPrice = price;
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
           bytes32 hash = keccak256(abi.encodePacked(domainNames[i]));
           premiumDomainPrices[hash] = prices[i];
        }
    }

    /**
    *
    * Domain names should performed before fill
    *
    **/
    function unsafeSetPremiumDomainPrice(string memory domainName, uint price) public onlyOwner {
       bytes32 hash = keccak256(abi.encodePacked(domainName));
       premiumDomainPrices[hash] = price;
    }

    function setPrices(uint newDefaultPrice, uint[] memory sizes, uint[] memory prices) public onlyOwner {
        require(sizes.length == prices.length, "Count of sizes and prices must be equals!");
        defaultPrice = newDefaultPrice;
        for(uint i = 0; i<sizes.length; i++) {
            pricePerNameLength[sizes[i]] = prices[i];
        }
    }

}
