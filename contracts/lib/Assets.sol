// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

library Assets {

    using EnumerableSet for EnumerableSet.UintSet;

    enum AssetType {
        NATIVE,
        ERC20
    }

struct Asset {
        string assetTicker;
        AssetType assetType;
        address assetAddress;   // ERC20 tokens only
    }

    struct Map {
        EnumerableSet.UintSet _keys;
        mapping(uint256 => Asset) _values;
    }

    function set(Map storage map, uint256 key, Asset memory value) internal returns (bool) {
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

    function at(Map storage map, uint256 index) internal view returns (uint256, Asset storage) {
        uint256 key = map._keys.at(index);
        return (key, map._values[key]);
    }

    function get(Map storage map, uint256 key) internal view returns (Asset storage) {
        Asset storage value = map._values[key];
        require(contains(map, key), "Assets.Map: nonexistent key");
        return value;
    }

}