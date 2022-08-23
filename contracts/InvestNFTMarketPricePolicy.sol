// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


import "./token/ERC721/ERC721.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./interfaces/IContentRouter.sol";

contract InvestNFTMarketPricePolicy is Ownable {

    function getPrice(uint sharePercent, uint count, address assetKey) public view returns(uint) {

    }

//    function setDefaultPrice(uint price) public onlyOwner {
//        defaultPrice = price;
//    }
//
//    function setPrice(uint size, uint price) public onlyOwner {
//        pricePerNameLength[size] = price;
//    }
//
//    function setPrices(uint newDefaultPrice, uint[] memory sizes, uint[] memory prices) public onlyOwner {
//        require(sizes.length == prices.length, "Count of sizes and prices must be equals!");
//        defaultPrice = newDefaultPrice;
//        for(uint i = 0; i<sizes.length; i++) {
//            pricePerNameLength[sizes[i]] = prices[i];
//        }
//    }

}
