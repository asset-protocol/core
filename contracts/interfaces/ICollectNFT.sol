// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ICollectNFT {
    function initialize(
        string calldata name_,
        string calldata symbol_,
        address publisher_,
        uint256 assetId_
    ) external;

    function mint(address to) external returns (uint256);

    function count(address collector) external view returns (uint256);
}
