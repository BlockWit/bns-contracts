// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./BNSNFT.sol";
import "./BNSMarketPricePolicy.sol";
import "./BNSNamesPolicy.sol";
import "./lib/Tokens.sol";
import "./PaymentHelper.sol";

contract BNSDomainNameMarket is Pausable, AccessControl, PaymentHelper {

    BNSMarketPricePolicy public pricePolicy;
    BNSNamesPolicy public namesPolicy;
    BNSNFT public bnsnft;
    address public fundraisingWallet;
    mapping (string => address) public domainBuyers;
    mapping (string => uint) public domainPrices;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setBNSNFT(address newBnsnft) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bnsnft = BNSNFT(newBnsnft);
    }

    function setFundraisingWallet(address newFundraisingWallet) public onlyRole(DEFAULT_ADMIN_ROLE) {
        fundraisingWallet = newFundraisingWallet;
    }

    function setPricePolicy(address newPricePolicy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        pricePolicy = BNSMarketPricePolicy(newPricePolicy);
    }

    function setNamesPolicy(address newNamesPolicy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        namesPolicy = BNSNamesPolicy(newNamesPolicy);
    }

    function setToken(uint256 key, address tokenAddress, Tokens.TokenType tokenType) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _setToken(key, tokenAddress, tokenType);
    }

    function removeToken(uint256 key) external returns (bool) {
        return _removeToken(key);
    }

    function buy(string memory domainName, uint256 tokenId) whenNotPaused external {
        // sanitize domain name and calculate price
        domainName = namesPolicy.perform(domainName);
        namesPolicy.check(domainName);
        require(!bnsnft.isDomainNameExists(domainName), "Domain name already exists");
        uint256 price = pricePolicy.getPrice(domainName, tokenId);
        // charge payment
        _transfer(msg.sender, fundraisingWallet, price, tokenId);
        // update statistics
        domainBuyers[domainName] = msg.sender;
        domainPrices[domainName] = price;
        // mint NFT
        bnsnft.safeMint(msg.sender, domainName);
    }

}
