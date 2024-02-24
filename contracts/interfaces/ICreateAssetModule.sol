// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICreateAssetModule {
    function processCreate(
        address publisher,
        uint256 assetId,
        bytes calldata data
    ) external returns (bytes memory);
}
