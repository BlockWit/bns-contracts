// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "../PaymentHelper.sol";

contract PaymentHelperMock is PaymentHelper {

    function setToken(uint256 key, address tokenAddress, Tokens.TokenType tokenType) external returns (bool) {
        return _setToken(key, tokenAddress, tokenType);
    }

    function removeToken(uint256 key) external returns (bool) {
        return _removeToken(key);
    }

    function transfer(address sender, address recipient, uint256 amount, uint256 currencyId) external {
        return _transfer(sender, recipient, amount, currencyId);
    }

}
