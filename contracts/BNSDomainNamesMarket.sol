// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

import "./BNSNFT.sol";
import "./BNSMarketPricePolicy.sol";
import "./BNSNamesPolicy.sol";
import "./StringUtils.sol";
import "./lib/Tokens.sol";

contract BNSDomainNameMarket is Pausable, AccessControl {

    using StringUtils for string;
    using Tokens for Tokens.Token;

    Tokens.Map currencies;

    BNSMarketPricePolicy public pricePolicy;

    BNSNamesPolicy public namesPolicy;

    BNSNFT public bnsnft;

    mapping (string => address) public domainBuyers;

    mapping (string => uint) public domainPrices;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setBNSNFT(address newBnsnft) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bnsnft = BNSNFT(newBnsnft);
    }

    function setPricePolicy(address newPricePolicy) public onlyRole(DEFAULT_ADMIN_ROLE) {
        pricePolicy = BNSMarketPricePolicy(newPricePolicy);
    }

    function setNamesPolicy(address newNamesPolicy) public onlyRole(DEFAULT_ADMIN_ROLE) {
        namesPolicy = BNSNamesPolicy(newNamesPolicy);
    }

    function getPrice(string memory domainName) public view returns(uint) {
        domainName = namesPolicy.perform(domainName);
        return getPriceForPerformedName(domainName);
    }

    function getPriceForPerformedName(string memory domainName) private view returns(uint) {
        require(!bnsnft.domainNameExists(domainName), "Domain name already exists");
        namesPolicy.check(domainName);
        return pricePolicy.getPrice(domainName);
    }

    function buy(string memory domainName, uint256 tokenId) whenNotPaused external payable {
        domainName = namesPolicy.perform(domainName);
        uint price = getPrice(domainName);
        require(msg.value >= price, "Not enough funds");
        uint change = msg.value - price;
        if(change != 0) {
            // check reentrancy
            (bool sent, ) = msg.sender.call{value: change}("");
            require(sent, "Failed to send change");
        }

        // for statistics
        domainBuyers[domainName] = msg.sender;
        domainPrices[domainName] = price;
        // TODO and other

        bnsnft.safeMint(msg.sender, domainName);
    }

}
