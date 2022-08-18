// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./RecoverableFunds.sol";
import "./interfaces/IContentRouter.sol";

contract BNSContentRouter is IContentRouter, RecoverableFunds, AccessControl {

    IContentProvider public defaultContentProvider;
    mapping(string => ContentRoute) public contentRoutes;

    bytes32 public constant CONTENT_MANAGER = keccak256("CONTENT_MANAGER");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setDefaultContentProvider(address newDefaultContentProvider) external onlyRole(DEFAULT_ADMIN_ROLE) {
        defaultContentProvider = IContentProvider(newDefaultContentProvider);
    }

    function setContentOrAddress(string memory name, string memory relativePath, string memory content, ContentType contentType, address contentProvider) override external onlyRole(CONTENT_MANAGER) {
        ContentRoute route = contentRoutes[name];
        route.exists = true;
        route.contentType = contentType;
        if (contentType == ContentType.INTERNAL) {
            if (contentProvider != 0x0) {
                route.contentProvider = contentProvider;
            } else if (route.contentProvider == 0x0) {
                route.contentProvider = defaultContentProvider;
            }
            route.contentProvider.setContent(name, relativePath, content);
        } else {
            route.contentAddress = content;
        }
    }

    function getContentOrAddress(string name, string relativePath) override external view returns (string memory) {
        ContentType contentType = contentRoutes[name].contentType;
        if (contentType == ContentType.INTERNAL) {
            return (contentType, getContent(name, relativePath));
        } else {
            return (contentType, getContentAddress(name, relativePath));
        }
    }

    function getContent(string memory name, string memory relativePath) public view returns (string memory) {
        ContentRoute memory route = contentRoutes[name];
        require(route.exists, "ContentRouter: Requested name record not found");
        require(route.contentType == ContentType.INTERNAL, "ContentRouter: This method is only used for internal content");
        return IContentProvider(route.contentProvider).getContent(name, relativePath);
    }

    function getContentAddress(string memory name, string relativePath) public view returns (string memory) {
        ContentRoute memory route = contentRoutes[name];
        require(route.exists, "ContentRouter: Requested name record not found");
        require(route.contentType == ContentType.EXTERNAL, "ContentRouter: This method is only used for external content");
        return route.contentAddress;
    }

}
