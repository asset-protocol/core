// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenTransfer {
    /**
     * @dev safeTransferERC20From
     * @param currency The currency.
     * @param from The sender.
     * @param amount The amount.
     */
    function safeTransferERC20From(
        address currency,
        address from,
        uint256 amount
    ) external;

    function safeTransferERC20(address currency, address to, uint256 amount) external;
}
