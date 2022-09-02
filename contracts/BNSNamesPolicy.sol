// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./lib/StringUtils.sol";
import "./RecoverableFunds.sol";

contract BNSNamesPolicy is Ownable, RecoverableFunds {

    using StringUtils for string;

    string public forbiddenSymbols = ".*/ ";

    uint256 public maxNameSizeLimit = 100;

    function setForbiddenSymbols(string calldata symbols) external onlyOwner {
        forbiddenSymbols = symbols;
    }

    function setMaxNameSizeLimit(uint256 limit) external onlyOwner {
        maxNameSizeLimit = limit;
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

    function check(string memory domainName) external view {
        require(domainName.length() > 0, "Domain name should not be empty!");
        require(domainName.length() <= maxNameSizeLimit, "Domain name is too long");
        if (domainName.containsAnyOf(forbiddenSymbols)) revert("Domain name contains forbidden symbol");
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyOwner {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyOwner {
        _retrieveETH(recipient);
    }

}
