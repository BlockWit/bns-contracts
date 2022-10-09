// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./token/ERC721/ERC721.sol";

contract BNSContentProvider is AccessControl {
    type tokenId is uint256;
    IERC721 public NFT;
    mapping(tokenId => bytes32) public content;

    bytes32 public constant ADMIN = keccak256("ADMIN");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN, msg.sender);
    }

    function setNFT(address newERC721) public onlyRole(ADMIN) {
        NFT = IERC721(newERC721);
    }

    function setContent(tokenId id, string memory newContent) public {
        require(msg.sender == NFT.ownerOf(tokenId.unwrap(id)), "Only token owner can set content");
        bytes32 newContentBytes = keccak256(abi.encodePacked(newContent));
        content[id] = newContentBytes;
    }

    function getContent(tokenId id) public view returns (bytes32) {
        return content[id];
    }

}
