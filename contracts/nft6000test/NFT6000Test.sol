// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFT6000Test is Ownable {

   mapping(uint => bool) public stopped;

   bool public transaction;

   uint public value;

   uint public index;

   uint public total;

   function accrueDividends(address assetAddress, address sharesAddress, uint count) public onlyOwner {
      IERC721Enumerable shares = IERC721Enumerable(sharesAddress);
      IERC20 asset = IERC20(assetAddress);
      if(!transaction) {
        transaction = true;
        //total = shares.totalSupply();
        total = 6000;
        value = 1;
        //value = asset.balanceOf(address(this))/total;
        index = 0;
      }
      uint remains = total - index;
      uint limit = index + remains;
      if(remains > count) {
        limit = index + count;
      } 
      for(; index < limit; index++) {
        if(stopped[index] == true) continue;
        asset.transfer(0x3552CB128b2c3a789a16c8f244eDC6a64Fe3eE93, value);
      }
      if(index == total - 1) {
         transaction = false;
      }
   }

}

