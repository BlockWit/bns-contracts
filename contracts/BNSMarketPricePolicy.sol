// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./StringUtils.sol";

contract BNSMarketPricePolicy is Ownable {

    using StringUtils for string;

    mapping (uint => uint) public pricePerNameLength;

    uint public defaultPrice;

    function getPrice(string memory domainName) public view returns(uint) {
        uint price = pricePerNameLength[domainName.length()];
        if(price == 0) price = defaultPrice;
        return price;
    }

    function setDefaultPrice(uint price) public onlyOwner {
        defaultPrice = price;
    }

    function setPrice(uint size, uint price) public onlyOwner {
        pricePerNameLength[size] = price;
    }

    function setPrices(uint newDefaultPrice, uint[] memory sizes, uint[] memory prices) public onlyOwner {
        require(sizes.length == prices.length, "Count of sizes and prices must be equals!");
        defaultPrice = newDefaultPrice;
        for(uint i = 0; i<sizes.length; i++) {
            pricePerNameLength[sizes[i]] = prices[i];
        }
    }

}
