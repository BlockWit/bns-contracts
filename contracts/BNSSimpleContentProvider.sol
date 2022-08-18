// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./RecoverableFunds.sol";
import "./interfaces/IContentProvider.sol";

contract BNSSimpleContentProvider is IContentProvider, RecoverableFunds, AccessControl {

    mapping(string => string) public domainNameToContent;

    bytes32 public constant CONTENT_MANAGER = keccak256("CONTENT_MANAGER");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setContent(string memory name, string memory relativePath, string memory content) override public onlyRole(CONTENT_MANAGER) {
        domainNameToContent[name] = content;
    }

    function getContent(string memory name, string memory relativePath) override public view returns (string memory) {
        return domainNameToContent[name];
    }

}
