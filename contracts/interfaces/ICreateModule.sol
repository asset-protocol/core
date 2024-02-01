// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICreateModule {
    function processCreate(
        address publisher,
        uint256 assetId,
        bytes calldata data
    ) external returns (bool, string memory);
}
