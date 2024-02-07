// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISubscribeModule {
    function initialModule(
        address publisher,
        uint256 assetId,
        bytes calldata data
    ) external returns (bytes memory);

    function processSubscribe(
        address subscriber,
        address publisher,
        uint256 assetId,
        bytes calldata data
    ) external returns (bytes memory);
}
