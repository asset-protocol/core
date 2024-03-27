// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICollectModule {
    function initialModule(
        address publisher,
        uint256 assetId,
        bytes calldata data
    ) external returns (bytes memory);

    function processCollect(
        address collector,
        address publisher,
        uint256 assetId,
        bytes calldata data
    ) external payable returns (bytes memory);
}
