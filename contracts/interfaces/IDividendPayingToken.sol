// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


interface IDividendPayingToken {

  struct Dividend {
    address assetKey;
    string assetTicker;
    uint256 amount;
  }

  function dividendOf(address owner) external view returns(Dividend[] memory);

  function distributeDividends() external payable;

  function withdrawDividend() external;

  function withdrawableDividendOf(address owner) external view returns(Dividend[] memory);

  function withdrawnDividendOf(address owner) external view returns(Dividend[] memory);

  function accumulativeDividendOf(address owner) external view returns(Dividend[] memory);

  event DividendsDistributed(
    address indexed from,
    uint256 amount,
    address assetKey
  );

  event DividendWithdrawn(
    address indexed to,
    uint256 amount,
    address assetKey
  );
}
