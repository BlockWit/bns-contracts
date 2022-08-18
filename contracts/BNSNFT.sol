// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BNSNFT is ERC721, ERC721Enumerable, Pausable, AccessControl {

    using Counters for Counters.Counter;

    BNSContentRouter public contentRouter;

    mapping(string => bool) public domainNameExists;
    mapping(uint256 => string) public tokenIdToDomainNames;
    mapping(string => uint256) public domainNamesToTokenId;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Blockchain Name Services NFT", "BNSNFT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }


    function getTokenIdByDomainName(string calldata domainName) public view returns (uint256)  {
        require(domainNameExists[domainName], "ERC721Metadata: Domain name not exists");
        return domainNamesToTokenId[domainName];
    }

    function getContent(uint256 tokenId, string memory relativePath) public view returns (string memory)  {
        require(_exists(tokenId), "ERC721Metadata: Content query for nonexistent token");
        string memory domainName = tokenIdToDomainNames[tokenId];
        return getContent(domainName, relativePath);
    }

    function getContent(string domainName, string memory relativePath) public view returns (string memory)  {
        return contentRouter.getContent(domainName, relativePath);
    }

    function getContentAddress(string domainName, string memory relativePath) public view returns (string memory)  {
        return contentRouter.getContentAddress(domainName, relativePath);
    }

    function setContentOrAddress(uint tokenId, string relativePath, String content, cotntenType, address contentProvider) only(...) {
        require(_exists(tokenId), "ERC721Metadata: Content query for nonexistent token");
        require(msg.sender == ownerOf(tokenId) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "ERC721Metadata: Content can set only admin or token owner");
        string memory domainName = tokenIdToDomainNames[tokenId];
	setContentOrAddress(domainName, relativePath, content, contentType, contentProvider);
    }

    function setContentOrAddress(string domainName, string relativePath, String content, cotntenType, address contentProvider) only(...) {
	contentRouter.setContentOrAddress(domainName, relativePath, content, contentType, contentProvider);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function safeMint(address to, string calldata domainName) public onlyRole(MINTER_ROLE) returns (uint256) {
        require(!domainNameExists[domainName], "Domain name already minted");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        domainNameExists[domainName] = true;
        tokenIdToDomainNames[tokenId] = domainName;
        domainNamesToTokenId[domainName] = tokenId;
        return tokenId;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
