// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./token/ERC721/ERC721.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./interfaces/IContentRouter.sol";

contract BNSNFT is ERC721, ERC721Enumerable, Pausable, AccessControl {

    using Counters for Counters.Counter;

    IContentRouter public contentRouter;

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

    function isDomainNameExists(string memory domainName) public view returns (bool) {
        return domainNameExists[domainName];
    }

    function getTokenIdByDomainName(string calldata domainName) public view returns (uint256)  {
        require(isDomainNameExists(domainName), "BNSNFT: Domain name not exists");
        return domainNamesToTokenId[domainName];
    }

    function getContent(uint256 tokenId, string memory relativePath) public view returns (IContentRouter.ContentType contentType, string memory)  {
        require(_exists(tokenId), "BNSNFT: Content query for nonexistent token");
        string memory domainName = tokenIdToDomainNames[tokenId];
        return getContent(domainName, relativePath);
    }

    function getContent(string memory domainName, string memory relativePath) public view returns (IContentRouter.ContentType contentType, string memory)  {
        return contentRouter.getContentOrAddress(domainName, relativePath);
    }

    function setContentOrAddress(uint tokenId, string memory relativePath, string memory content, IContentRouter.ContentType contentType, address contentProvider) external {
        require(msg.sender == ownerOf(tokenId) || hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "BNSNFT: Only admin or token owner can set content");
        require(_exists(tokenId), "BNSNFT: Content query for nonexistent token");
        string memory domainName = tokenIdToDomainNames[tokenId];
	    contentRouter.setContentOrAddress(domainName, relativePath, content, contentType, contentProvider);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }


    /**
     *
     * Check domain names before call this method!!!
     *
     **/
    function unsafeBatchMint(address to, string[] calldata domainNames) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint i = 0; i < domainNames.length; i++) {
           uint256 tokenId = _tokenIdCounter.current();
           _tokenIdCounter.increment();
           _balances[to] += 1;
           _owners[tokenId] = to;
           domainNameExists[domainNames[i]] = true;
           tokenIdToDomainNames[tokenId] = domainNames[i];
           domainNamesToTokenId[domainNames[i]] = tokenId;
        }
    }

    function safeBatchMint(address to, string[] calldata domainNames) public onlyRole(DEFAULT_ADMIN_ROLE) {
        for(uint i = 0; i < domainNames.length; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _balances[to] += 1;
            _safeMint(to, tokenId);
        }
    }

    function safeMint(address to, string calldata domainName) public onlyRole(MINTER_ROLE) returns (uint256) {
        require(!isDomainNameExists(domainName), "BNSNFT: Domain name already exists");
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
