// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

abstract contract BookKeeper {

    uint256 constant internal MAX_SUPPLY = 1_000_000 ether;

    mapping(uint256 => uint256) internal _balances;
    uint256 internal _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(uint256 account) public view returns (uint256) {
        return _balances[account];
    }

    function _mint(uint256 account, uint256 amount) internal virtual {
        _totalSupply += amount;
        require(_totalSupply <= MAX_SUPPLY, "BookKeeper: total supply exceeds the maximum allowable");
        _balances[account] += amount;
    }

    function _burn(uint256 account, uint256 amount) internal virtual {
        require(_balances[account] >= amount, "BookKeeper: burn amount exceeds balance");
        _balances[account] -= amount;
        _totalSupply -= amount;
    }

}
