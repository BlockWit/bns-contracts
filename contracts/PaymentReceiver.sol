// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.14;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./RecoverableFunds.sol";

contract PaymentReceiver is AccessControl, RecoverableFunds {

    event TokenPaid(
        uint256 indexed taskId,
        address indexed buyer,
        uint256 amount
    );

    address public recipient;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        recipient = address(this);
    }

    function setRecipient(address newRecipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        recipient = newRecipient;
    }

    function processPayment(address token, address sender, uint256 amount, uint256 taskId, address buyer) external payable {
        IERC20(token).transferFrom(sender, recipient, amount);
        emit TokenPaid(taskId, buyer, amount);
    }

    function retrieveTokens(address recipient, address tokenAddress) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveTokens(recipient, tokenAddress);
    }

    function retrieveETH(address payable recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _retrieveETH(recipient);
    }

}
