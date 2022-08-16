// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./StringUtils.sol";

contract BNSNamesPolicy is AccessControl {

    using StringUtils for string;

    string public forbiddenSymbols = ".*/ ";

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setForbiddenSymbols(string calldata symbols) external onlyRole(DEFAULT_ADMIN_ROLE) {
        forbiddenSymbols = symbols;
    }

    function perform(string memory domainName) external pure returns(string memory) {
        domainName = domainName.lower();
        return domainName;
    }

    function _indexOf(string memory _base, bytes memory _value, uint _offset) internal pure returns (int) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = _offset; i < _baseBytes.length; i++) {
            if (_baseBytes[i] == _value[0]) {
                return int(i);
            }
        }
        return -1;
    }

    function check(string memory domainName) external pure {
        require(domainName.length() > 0, "Domain name should not be empty!");
        bytes memory _forbiddenSymbols = bytes(forbiddenSymbols);
        for (uint i = 0; i < _forbiddenSymbols.length; i++) {
            if (_indexOf(domainName, _forbiddenSymbols[i], 0) >= 0) revert("Domain name contains forbidden symbol");
        }
    }

}
