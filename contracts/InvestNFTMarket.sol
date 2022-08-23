// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./AssetHandler.sol";

import "./lib/Assets.sol";
import "./InvestNFT.sol";
import "./InvestNFTMarketPricePolicy.sol";

contract InvestNFTMarket is AccessControl, Pausable, AssetHandler {

    InvestNFT public investNFT;

    InvestNFTMarketPricePolicy public investNFTMarketPricePolicy;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setInvestNFT(address newInvestNFT) public onlyRole(DEFAULT_ADMIN_ROLE) {
        investNFT = InvestNFT(newInvestNFT);
    }

    function setInvestNFTMarketPolicy(address newInvestNFTMarketPricePolicy) public onlyRole(DEFAULT_ADMIN_ROLE) {
        investNFTMarketPricePolicy = InvestNFTMarketPricePolicy(newInvestNFTMarketPricePolicy);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function getPrice(uint sharePercent, uint count, address assetKey) public returns (uint, uint) {
        uint countOfSharesWithPercent = investNFT.getCountOfSharesWithPercent(address(this), sharePercent);
        require(countOfSharesWithPercent > 0, "No more shares with specified percent");
        if(count > countOfSharesWithPercent) {
            count = countOfSharesWithPercent;
        }
        uint price = investNFTMarketPricePolicy.getPrice(sharePercent, count, assetKey);
        return (price, count);
    }

    function buy(uint sharePercent, uint count, address assetKey) public {
        uint countOfSharesWithPercent = investNFT.getCountOfSharesWithPercent(address(this), sharePercent);
        require(countOfSharesWithPercent > 0, "No more shares with specified percent");
        if(count > countOfSharesWithPercent) {
            count = countOfSharesWithPercent;
        }

        uint price = investNFTMarketPricePolicy.getPrice(sharePercent, count, assetKey);

        // charge payment
        _transferAssetFrom(msg.sender, address(this), price, assetKey);
        (uint startIndexSameShares, uint endIndexSameShares)  = investNFT.getIndexesOfSharesWithPercents(address(this), sharePercent);
        for(uint i = 1; i < count + 1; i++) {
            uint tokenId = startIndexSameShares + i - 1;
            if(investNFT.ownerOf(tokenId) == address(this)) {
                investNFT.transferFrom(address(this), msg.sender, tokenId);
            } else {
                i--;
            }
        }
    }

     // FIXME: return all tokens with recoverable funds

}
