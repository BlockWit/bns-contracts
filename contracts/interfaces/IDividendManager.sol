// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;
import "../lib/Assets.sol";


interface IDividendManager {

  type AccountId is uint256;

  struct Dividend {
    Assets.Key assetKey;
    string assetTicker;
    uint256 amount;
  }

  function mint(AccountId account, uint256 amount) external;

  function burn(AccountId account, uint256 amount) external;

  function dividendOf(AccountId account) external view returns(Dividend[] memory);

  function distributeDividends(uint256 amount, Assets.Key assetKey) external;

  function withdrawDividend(AccountId account) external;

  function withdrawableDividendOf(AccountId account) external view returns(Dividend[] memory);

  function withdrawnDividendOf(AccountId account) external view returns(Dividend[] memory);

  function accumulativeDividendOf(AccountId account) external view returns(Dividend[] memory);

  event DividendsDistributed(
    address indexed from,
    uint256 amount,
    Assets.Key assetKey
  );

  event DividendWithdrawn(
    AccountId indexed to,
    uint256 amount,
    Assets.Key assetKey
  );
}
