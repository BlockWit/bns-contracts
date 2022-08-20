// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./DividendPayingToken.sol";

contract BNSToken is DividendPayingToken {
    constructor(string memory name, string memory symbol, address initialAccount, uint256 initialBalance) payable ERC20(name, symbol) {
        _mint(initialAccount, initialBalance);
    }
}
