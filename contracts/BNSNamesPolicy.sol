// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

import "./StringUtils.sol";

contract BNSNamesPolicy is Ownable {

    using StringUtils for string;

    function perform(string memory domainName) public pure returns(string memory) {
        //TODO: to lower case
        return domainName;
    }

    function check(string memory domainName) public pure {
        uint length = domainName.length();
        require(length > 0, "Domain name should not be empty!");
    }

}
