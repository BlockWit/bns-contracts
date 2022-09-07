// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

/**
 * UTF8 Utils
 */
library UTF8Utils {

    function length(string memory _self) internal pure returns (uint256 length) {
        bytes memory _bytes = bytes(_self);
        uint256 i = 0;
        while (i < _bytes.length) {
            i += _getCharSize(_bytes[i]);
            length++;
        }
    }

    function getFirstCharCodepoint(string memory _self) external pure returns (uint256) {
        bytes memory _bytes = bytes(_self);
        bytes1 firstByte = _bytes[0];
        if (firstByte >> 7 == bytes1(0)) {
            // this is a single byte UTF-8 char
            return uint8(firstByte);
        } else if (firstByte >> 5 == bytes1(uint8(0x6))) {
            // two byte UTF-8 char
            return uint16((firstByte & 0x1f) >> 2 | bytes2(_bytes[1] & 0x3f) >> 8);
        } else if (firstByte >> 4 == bytes1(uint8(0xe))) {
            // three byte UTF-8 char
            return uint16((firstByte & 0x1f) << 4 | bytes2(_bytes[1] & 0x3f) >> 2 | bytes2(_bytes[2] & 0x3f) >> 8);
        } else if (firstByte >> 3 == bytes1(uint8(0x1e))) {
            // four byte UTF-8 char
            return uint24((firstByte & 0x07) << 2 | bytes2(_bytes[1] & 0x3f) >> 4 | bytes3(_bytes[2] & 0x3f) >> 10 | bytes3(_bytes[3] & 0x3f) >> 16);
        } else {
            revert("UTF8Utils: unsupported character");
        }
    }

    function _getCharSize(bytes1 _byte1) internal pure returns (uint8 size) {
        if (_byte1 >> 7 == 0) size = 1;
        else if (_byte1 >> 5 == bytes1(uint8(0x6))) size = 2;
        else if (_byte1 >> 4 == bytes1(uint8(0xE))) size = 3;
        else if (_byte1 >> 3 == bytes1(uint8(0x1E))) size = 4;
        else revert("UTF8Utils: unsupported character");
    }

}
