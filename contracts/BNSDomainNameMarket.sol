// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./interfaces/IDividendManager.sol";
import "./lib/Assets.sol";
import "./BNSNFT.sol";
import "./AssetHandler.sol";

contract BNSDomainNameMarket is Pausable, AccessControl, AssetHandler, RecoverableFunds {

    BNSNFT public bnsnft;
    IDividendManager public dividendManager;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    mapping(Assets.Key => uint) public dividendsLimit;
    mapping(address => CustomMint) public customMints;

    struct CustomMint {
        string[] domainNames;
        address refererAddress;
        uint refererBonus;
        Assets.Key assetKey;
        bool performed;
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function setBNSNFT(address newBnsnft) public onlyRole(DEFAULT_ADMIN_ROLE) {
        bnsnft = BNSNFT(newBnsnft);
    }

    function setDividendManager(address newDividendManager) public onlyRole(DEFAULT_ADMIN_ROLE) {
        dividendManager = IDividendManager(newDividendManager);
    }

    function setAsset(Assets.Key key, string memory assetTicker, Assets.AssetType assetType) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _setAsset(key, assetTicker, assetType);
    }

    function removeAsset(Assets.Key key) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return _removeAsset(key);
    }

    function createCustomMint(address buyer, string[] memory domainNames, address refererAddress, uint refererBonus, Assets.Key assetKey) external onlyRole(MINTER_ROLE) {
        customMints[buyer] = CustomMint(domainNames, refererAddress, refererBonus, assetKey, false);
        dividendsLimit[assetKey] = dividendsLimit[assetKey] + refererBonus;
    }

    function getCustomMint(address addr) external view returns (CustomMint memory) {
        return customMints[addr];
    }

    function performCustomMint() external {
        CustomMint storage customMint = customMints[msg.sender];
        require(!customMint.performed, "Already performed!");

        if (customMint.refererBonus > 0) {
            _transferAsset(customMint.refererAddress, customMint.refererBonus, customMint.assetKey);
            dividendsLimit[customMint.assetKey] = dividendsLimit[customMint.assetKey] - customMint.refererBonus;
        }

        bnsnft.safeBatchMint(msg.sender, customMint.domainNames);
        customMint.performed = true;
    }

    function sendDividends(Assets.Key assetKey, uint amount) whenNotPaused public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(IERC20(Assets.Key.unwrap(assetKey)).balanceOf(address(this)) >= amount + dividendsLimit[assetKey], "DividendLimit exceeds amount you want to distribute!");

        _approveAsset(address(dividendManager), amount, assetKey);
        dividendManager.distributeDividends(amount, assetKey);
    }

    function sendDividends(Assets.Key assetKey) whenNotPaused external onlyRole(DEFAULT_ADMIN_ROLE) {
        sendDividends(assetKey, IERC20(Assets.Key.unwrap(assetKey)).balanceOf(address(this)) - dividendsLimit[assetKey]);
    }

    function buy(string[] memory domainNames, uint price, address buyer, address referer, uint refererBonus, Assets.Key assetKey, bool flag) whenNotPaused external onlyRole(MINTER_ROLE) {
        if (price != 0) {
            // charge payment
            if (flag == false) {
                _transferAssetFrom(buyer, address(this), price, assetKey);
            }
            if (refererBonus > 0) {
                _transferAsset(referer, refererBonus, assetKey);
            }
        }
        // mint all NFT
        bnsnft.safeBatchMint(buyer, domainNames);
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveETH(recipient);
    }

}
