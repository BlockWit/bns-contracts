// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./RecoverableFunds.sol";

contract BNSSimpleContentProvider is RecoverableFunds, AccessControll {

    mapping(string => string) public domainNameToContent;

    function configure() public onlyOwner {
	// TO ADMIN
    }

    function public setContent(name, relativePath, content) public onlyRole(admin, parent) {
        domainNameToContent[name] = content;
    }

    function public getContent(name, relativePath) public view returns (string memory) {
        return domainNameToContent[name];
    }

}
