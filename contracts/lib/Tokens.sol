// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library Tokens {

    using EnumerableSet for EnumerableSet.UintSet;

    enum Currency {
        ERC20,
        NATIVE
    }

    struct Token {
        address addr;
        Currency currencyType;
    }

    function transferFrom(Token memory currency, address sender, address recipient, uint256 amount) internal {
        if (currency.currencyType == Currency.ERC20) {
            IERC20(currency.addr).transferFrom(sender, recipient, amount);
        } else {
            payable(recipient).transfer(amount);
        }
    }

    struct Map {
        EnumerableSet.UintSet _keys;
        mapping(uint256 => Token) _values;
    }

    function set(Map storage map, uint256 key, Token memory value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    function remove(Map storage map, uint256 key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    function contains(Map storage map, uint256 key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    function length(Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    function at(Map storage map, uint256 index) internal view returns (uint256, Token storage) {
        uint256 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function get(Map storage map, uint256 key) internal view returns (Token storage) {
        Token storage value = map._values[key];
        require(contains(map, key), "Tokens.Map: nonexistent key");
        return value;
    }

}
