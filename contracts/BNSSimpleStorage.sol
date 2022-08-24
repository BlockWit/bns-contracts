// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./RecoverableFunds.sol";

contract BNSSimpleStorage is Ownable, RecoverableFunds {

    mapping(string => string) public content;

    function setContent(string memory target, string memory newContent) public onlyOwner {
        content[target] = newContent;
    }

    function getContent(string memory name) public view returns (string memory) {
        return content[name];
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyOwner {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyOwner {
        _retrieveETH(recipient);
    }

}
