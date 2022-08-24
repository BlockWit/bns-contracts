// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;


contract DiscountCalculator {

    struct Discount {
        uint256 numerator;
        uint256 denominator;
        uint256 validThru;
    }

    Discount[] public discounts;

    function _setDiscount(uint256 index, Discount calldata discount) internal {
        discounts[index] = discount;
    }

    function calculateDiscount(uint256 amount, uint256 timestamp) public view returns (uint256) {
        uint256 i;
        Discount memory discount;
        while (discounts[i].validThru >= timestamp) {
            discount = discounts[i];
            i++;
        }
        return discount.denominator > 0 ? amount * discount.numerator / discount.denominator : 0;
    }

}
