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

    uint public price;

    function getPrice(uint count, address assetKey) public view returns (uint) {
        return price;
    }

    function setPrice(uint newPrice) public onlyOwner {
        price = newPrice;
    }

}
