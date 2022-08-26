// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;


contract DiscountCalculator {

    struct Discount {
        uint256 numerator;
        uint256 denominator;
        uint256 validThru;
    }

    Discount[] public discounts;

    function _setDiscount(Discount[] calldata discounts) internal {
        discounts[index] = discount;
        if(this.discounts.length == discounts.length) {
            for(uint i = 0; i < discounts.length; i++) {
                this.discounts[i] = discounts[i];
            }
        }
        if(this.discounts.length > discounts.length) {
            uint lengthDiff = this.discounts.length - discounts.length;
            for(uint i = 0; i < lengthDiff; i++) {
                this.discounts.pop();
            }
            for(uint i = 0; i < discounts.length; i++) {
                this.discounts[i] = discounts[i];
            }
        }
        if(this.discounts.length < discounts.length) {
            uint i;
            uint lengthDiff = discounts.length - this.discounts.length;
            for(i = 0; i < this.discounts.length; i++) {
                this.discounts[i] = discounts[i];
            }
            while(lengthDiff > 0) {
                i++;
                this.discounts.push(discounts[i]);
                lengthDiff--;
            }
        }
    }

    function calculateDiscount(uint256 amount, uint256 timestamp) public view returns (uint256) {
        uint256 i = this.discounts.length;
        Discount memory discount;
        while (discounts[i].validThru >= timestamp) {
            discount = discounts[i];
            i--;
        }
        return discount.denominator > 0 ? amount * discount.numerator / discount.denominator : 0;
    }

}
