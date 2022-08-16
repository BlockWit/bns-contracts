// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/Tokens.sol";

contract PaymentController is AccessControl {

    using Tokens for Tokens.Map;

    Tokens.Map tokens;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setToken(uint256 key, address tokenAddress, Tokens.TokenType tokenType) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return tokens.set(key, Tokens.Token(tokenAddress, tokenType));
    }

    function removeToken(uint256 key) external onlyRole(DEFAULT_ADMIN_ROLE) returns (bool) {
        return tokens.remove(key);
    }

    function tokensLength() external view returns (uint256) {
        return tokens.length();
    }

    function getTokenAt(uint256 index) external view returns (uint256, Tokens.Token memory) {
        return tokens.at(index);
    }

    function getToken(uint256 key) external view returns (Tokens.Token memory) {
        return tokens.get(key);
    }

    function transfer(address sender, address recipient, uint256 amount, uint256 currencyId) external {
        Tokens.Token memory token = tokens.get(currencyId);
        IERC20(token.tokenAddress).transferFrom(sender, recipient, amount);
    }

}
