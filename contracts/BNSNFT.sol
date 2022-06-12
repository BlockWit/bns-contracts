// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BNSNFT is ERC721, ERC721Enumerable, Pausable, AccessControl {

    using Counters for Counters.Counter;

    mapping(string => bool) public domainNameExists;
    mapping(string => string) public domainNamesToContents;
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

    //    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
    //        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    //        return contents[tokenId];
    //    }

    function getTokenIdByDomainName(string calldata domainName) public view returns (uint256)  {
        require(domainNameExists[domainName], "ERC721Metadata: Domain name not exists");
        return domainNamesToTokenId[domainName];
    }

    function getContent(uint256 tokenId) public view returns (string memory)  {
        require(_exists(tokenId), "ERC721Metadata: Content query for nonexistent token");
        string memory domainName = tokenIdToDomainNames[tokenId];
        return domainNamesToContents[domainName];
    }

    function setContent(uint256 tokenId, string calldata content) public {
        require(_exists(tokenId), "ERC721Metadata: Content query for nonexistent token");
        require(msg.sender == ownerOf(tokenId) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "ERC721Metadata: Content can set only admin or token owner");
        string memory domainName = tokenIdToDomainNames[tokenId];
        domainNamesToContents[domainName] = content;
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
