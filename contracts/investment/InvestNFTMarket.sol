// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "../lib/Assets.sol";
import "../AssetHandler.sol";
import "../RecoverableFunds.sol";
import "./InvestNFT.sol";
import "./InvestNFTMarketPricePolicy.sol";

contract InvestNFTMarket is AccessControl, Pausable, AssetHandler, RecoverableFunds {

    InvestNFT public investNFT;

    InvestNFTMarketPricePolicy public investNFTMarketPricePolicy;

    uint public sharesToBuyLimit;

    uint public sharesBought;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setSharesToBuyLimit(uint newSharesToBuyLimit) public onlyRole(DEFAULT_ADMIN_ROLE) {
        sharesToBuyLimit = newSharesToBuyLimit;
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

    function canBuy() public view returns (uint) {
        uint canMintNFT;
        uint canBuyNFT = sharesToBuyLimit - sharesBought;
        return canMintNFT > canBuyNFT ? canBuyNFT : canMintNFT;
    }

    function getPrice(uint count, Assets.Key assetKey) public view returns (uint, uint) {
        uint countOfSharesCanMint = canBuy();
        if (count > countOfSharesCanMint) {
            count = countOfSharesCanMint;
        }
        uint price = 0;
        if(count > 0) {
            price = investNFTMarketPricePolicy.getPrice(count, assetKey);
        }
        return (price, count);
    }

    function buy(uint count, Assets.Key assetKey) public {
        require(sharesBought <= sharesToBuyLimit, "All shares bought!");
        uint countOfSharesCanMint = canBuy();
        require(countOfSharesCanMint > 0, "No more shares!");
        if (count > countOfSharesCanMint) {
            count = countOfSharesCanMint;
        }

        uint price = investNFTMarketPricePolicy.getPrice(count, assetKey);

        // charge payment
        sharesBought += count;
        _transferAssetFrom(msg.sender, address(this), price, assetKey);
        investNFT.safeMint(msg.sender, count);
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveETH(recipient);
    }

}
