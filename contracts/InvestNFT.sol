// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./token/ERC721/ERC721.sol";
import "./token/ERC721/extensions/ERC721Enumerable.sol";
import "./interfaces/IContentRouter.sol";

contract InvestNFT is ERC721, ERC721Enumerable, Pausable, AccessControl {

    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    Counters.Counter private _tokenIdCounter;

    mapping(uint => uint) shareToPercent;

    uint public PERCENT_RATE = 100;

    uint public summaryPercent;

    constructor() ERC721("Blockchain Name Services invest NFT", "BNSI") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /*
    * safePreMintForSameShares(NFT owner, 5, 25);
    * safePreMintForSameShares(NFT owner, 10, 10);
    * safePreMintForSameShares(NFT owner, 20, 10);
    * safePreMintForSameShares(NFT owner, 100, 10);
    * safePreMintForSameShares(NFT owner, 200, 10);
    * safePreMintForSameShares(NFT owner, 200, 2); x10
    * safePreMintForSameShares(NFT owner, 200, 1); x15
    *
    */
    function safePreMintForSameShares(address to, uint countsOfSameShares, uint percentsPerAllSameShare) public onlyRole(MINTER_ROLE) {
        summaryPercent += percentsPerAllSameShare;
        uint percentPerShare = percentsPerAllSameShare * (1 ether) / countsOfSameShares;
        require(summaryPercent <= PERCENT_RATE, "Sum of common percents for all shares must be equals to 100");
        for (uint i = 0; i < countsOfSameShares; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
            shareToPercent[tokenId] = percentPerShare;
        }
    }

    function getCountOfSharesWithPercent(address target, uint percentPerShare) public returns(uint) {
        // TODO:
        return 0;
    }

    function getIndexesOfSharesWithPercents(address target, uint percentPerShare) public returns (uint, uint) {
        // TODO:
        return (12,12);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}
