// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;


contract DiscountCalculator {

    struct Discount {
        uint256 numerator;
        uint256 denominator;
        uint256 validThru;
    }

    Discount[] public discounts;

    function _setDiscount(Discount[] calldata newDiscounts) internal {
        if(discounts.length == 0) {
            for(uint i = 0; i < newDiscounts.length; i++) {
                discounts.push(newDiscounts[i]);
            }
        }
        if(discounts.length == newDiscounts.length) {
            for(uint i = 0; i < newDiscounts.length; i++) {
                discounts[i] = newDiscounts[i];
            }
        }
        if(discounts.length > newDiscounts.length) {
            uint lengthDiff = discounts.length - newDiscounts.length;
            for(uint i = 0; i < lengthDiff; i++) {
                discounts.pop();
            }
            for(uint i = 0; i < newDiscounts.length; i++) {
                discounts[i] = newDiscounts[i];
            }
        }
        if(discounts.length < newDiscounts.length) {
            uint i;
            uint lengthDiff = newDiscounts.length - discounts.length;
            for(i = 0; i < discounts.length; i++) {
                discounts[i] = newDiscounts[i];
            }
            while(lengthDiff > 0) {
                i++;
                discounts.push(newDiscounts[i]);
                lengthDiff--;
            }
        }
    }

    function calculateDiscount(uint256 amount, uint256 timestamp) public view returns (uint256) {
        uint256 i = discounts.length;
        Discount memory discount;
        while (discounts[i].validThru >= timestamp) {
            discount = discounts[i];
            i--;
        }
        return discount.denominator > 0 ? amount * discount.numerator / discount.denominator : 0;
    }

}
