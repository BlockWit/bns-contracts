// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "../RecoverableFunds.sol";

contract InvestNFT is ERC721Enumerable, Pausable, AccessControl, RecoverableFunds {

    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    Counters.Counter private _tokenIdCounter;

    uint public PERCENT_RATE = 100000;
    uint public PERCENT_PER_SHARE = 5;
    uint public SHARES_LIMIT = PERCENT_RATE / PERCENT_PER_SHARE;
    uint public summaryMintedShares;

    constructor() ERC721("Blockchain Name Services Investment NFT", "BNSI") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function pause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    function canMint() public view returns (uint) {
        return SHARES_LIMIT - summaryMintedShares;
    }

    function safeMint(address to, uint count) public onlyRole(MINTER_ROLE) {
        summaryMintedShares += count;
        require(summaryMintedShares <= SHARES_LIMIT, "Can't mint specified count of shares. Limit exceeded!");
        for (uint i = 0; i < count; i++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(to, tokenId);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal whenNotPaused override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveETH(recipient);
    }

}
