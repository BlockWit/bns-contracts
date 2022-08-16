// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./BNSNFT.sol";
import "./BNSMarketPricePolicy.sol";
import "./BNSNamesPolicy.sol";
import "./PaymentController.sol";
import "./lib/Tokens.sol";

contract BNSDomainNameMarket is Pausable, AccessControl {

    PaymentController public paymentController;
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

    function setPaymentController(address newPaymentController) external onlyRole(DEFAULT_ADMIN_ROLE) {
        paymentController = PaymentController(newPaymentController);
    }

    function setPricePolicy(address newPricePolicy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        pricePolicy = BNSMarketPricePolicy(newPricePolicy);
    }

    function setNamesPolicy(address newNamesPolicy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        namesPolicy = BNSNamesPolicy(newNamesPolicy);
    }

    function buy(string memory domainName, uint256 tokenId) whenNotPaused external {
        // sanitize domain name and calculate price
        domainName = namesPolicy.perform(domainName);
        namesPolicy.check(domainName);
        require(!bnsnft.domainNameExists(domainName), "Domain name already exists");
        uint256 price = pricePolicy.getPrice(domainName, tokenId);
        // charge payment
        paymentController.transfer(msg.sender, fundraisingWallet, price, tokenId);
        // update statistics
        domainBuyers[domainName] = msg.sender;
        domainPrices[domainName] = price;
        // mint NFT
        bnsnft.safeMint(msg.sender, domainName);
    }

}
