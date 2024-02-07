// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenTransfer {
    /**
     * @dev safeSendErc20From
     * @param currency The currency.
     * @param from The sender.
     * @param amount The amount.
     */
    function safeSendErc20From(address currency, address from, uint256 amount) external;

    function safeSendErc20(address currency, address to, uint256 amount) external;

    function safeTransferErc20From(
        address currency,
        address from,
        address to,
        uint256 amount
    ) external;

    function verifyErc20Currency(address currency) external returns (bool);
}
