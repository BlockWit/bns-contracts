// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./RecoverableFunds.sol";

contract BNSContentRouter is RecoverableFunds, AccessControl {

    uint8 public constant CONTENT_TYPE_INTERNAL = 0;

    uint8 public constant CONTENT_TYPE_EXTERNAL = 1;

    BNSContentProvider public defaultContentProvider;

    mapping(string => ContentRecord) public contentRoutes;

    struct ContentRoute {
        bool exists;
        uint8 contentType;
        IBNSContentPtovider contentProvider; // отдается, если контент внутренний
        string contentAddress; // Отдается, если контент внешний
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); // должна быть еще роль для BNSNFT
    }

    function setContentOrAddress(string memory name, string relativePath, String content, cotntenType, address contentProvider) only(BNSNFT, admin) {
      if(contentTypeinternal) {
         ContentRoute contentRoute = contentRoutes[name];
         if(!contentRoute.exists) {
           contentRoute.exists = true;
           contentRoute.contentType = contentType;
           if(contentType == CONTENT_TYPE_INTERNAL) {
              if(contentProvider != 0xx)
                 contentRoute.contentProvider = contentProvider;
              else 
                 contentRoute.contentProvider = defaultContentProvider;
              contentRoute.contentProvider.setContent(name, relativePath, content);
           } else {
              contentRoute.contentAddress = content;
           }
         } else {
           if(contentType == CONTENT_TYPE_INTERNAL) {
              contentRoute.contentProvider.setContent(name, relativePath, content);
           } else {
              contentRoute.contentAddress = content;
           }
         }
       }
    } 

    function getContent(string memory name, string relativePath) public view returns (string memory) {
        ContentRecord memory contentRecord = contentRecords[name];
        require(contentRecord.exists, "Requested name record not found!");
        require(contentRecord.contentType == CONTENT_TYPE_INTERNAL, "Route for requested name not found!");
        return contentProvider.getContent(name, realtivePath);
    }

    function getContentAddress(string memory name, string relativePath) public view returns (string memory) {
        require(contentRecord.exists, "Requested name record not found!");
        require(contentRecord.contentType == CONTENT_TYPE_ETERNAL, "Route for requested name not found!");
        return contentProvider.contentAddress;
    }

}
