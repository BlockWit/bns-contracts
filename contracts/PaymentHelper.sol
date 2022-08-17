// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./lib/Tokens.sol";

contract PaymentHelper {

    using Tokens for Tokens.Map;

    Tokens.Map tokens;

    function _setToken(uint256 key, address tokenAddress, Tokens.TokenType tokenType) internal virtual returns (bool) {
        return tokens.set(key, Tokens.Token(tokenAddress, tokenType));
    }

    function _removeToken(uint256 key) internal virtual returns (bool) {
        return tokens.remove(key);
    }

    function tokensLength() public view returns (uint256) {
        return tokens.length();
    }

    function getTokenAt(uint256 index) public view returns (uint256, Tokens.Token memory) {
        return tokens.at(index);
    }

    function getToken(uint256 key) public view returns (Tokens.Token memory) {
        return tokens.get(key);
    }

    function _transfer(address sender, address recipient, uint256 amount, uint256 currencyId) internal {
        Tokens.Token memory token = tokens.get(currencyId);
        IERC20(token.tokenAddress).transferFrom(sender, recipient, amount);
    }

}
