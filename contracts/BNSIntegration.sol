// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./BNSNFT.sol";
import "./BNSMarketPricePolicy.sol";
import "./BNSDomainNamesMarket.sol";
import "./BNSNamesPolicy.sol";


contract BNSIntegration is Ownable {

    BNSDomainNamesMarket public market;

    BNSMarketPricePolicy public pricePolicy;

    BNSNamesPolicy public namesPolicy;

    BNSNFT public bnsnft;

    function init() public onlyOwner() {
       createContracts();
       initRelations();
       fillInitialValues();
    }


    function createContracts() public onlyOwner {
        market = new BNSDomainNamesMarket();
        pricePolicy = new BNSMarketPricePolicy();
        namesPolicy = new BNSNamesPolicy();
        bnsnft = new BNSNFT();
    }   

    function initRelations() public onlyOwner {
        market.setBNSNFT(bnsnft);
        market.setPricePolicy(pricePolicy);
        market.setNamesPolicy(namesPolicy);
    }   
   

    function fillInitialValues() public onlyOwner {
       // TODO: fill predefined NFT's

       // fill prices
       uint[] sizes = [1,2,3,4,5,6,7,8];
       uint[] pricesUSDT = [300000,250000,200000,100000,50000,10000,1000,100];
       pircePolicy.setPrices(sizes, pricesUSDT, 30);
    }   
   

}
