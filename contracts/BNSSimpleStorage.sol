// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "./RecoverableFunds.sol";

contract BNSSimpleStorage is RecoverableFunds {

    mapping(string => string) public content;

    function setContent(string memory target, string memory newContent) public onlyOwner {
        content[target] = newContent;
    }

    function getContent(string memory name) public view returns (string memory) {
        return content[name];
    }

}
