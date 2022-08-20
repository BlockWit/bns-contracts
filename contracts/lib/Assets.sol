// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library Assets {

    using EnumerableSet for EnumerableSet.AddressSet;

    enum AssetType {
        NATIVE,
        ERC20
    }

    struct Asset {
        string assetTicker;
        AssetType assetType;
    }

    struct Map {
        EnumerableSet.AddressSet _keys;
        mapping(address => Asset) _values;
    }

    function set(Map storage map, address key, Asset memory value) internal returns (bool) {
        map._values[key] = value;
        return map._keys.add(key);
    }

    function remove(Map storage map, address key) internal returns (bool) {
        delete map._values[key];
        return map._keys.remove(key);
    }

    function contains(Map storage map, address key) internal view returns (bool) {
        return map._keys.contains(key);
    }

    function length(Map storage map) internal view returns (uint256) {
        return map._keys.length();
    }

    function at(Map storage map, uint256 index) internal view returns (address, Asset storage) {
        address key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function get(Map storage map, address key) internal view returns (Asset storage) {
        Asset storage value = map._values[key];
        require(contains(map, key), "Assets.Map: nonexistent key");
        return value;
    }

}
