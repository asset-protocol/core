// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISubscribeModule {
    function processSubscribe(
        address subscriber,
        address publisher,
        uint256 assetId,
        bytes calldata data
    ) external returns (bool, string memory);
}
