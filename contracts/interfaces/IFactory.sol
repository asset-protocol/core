// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IFactory {
    function create(bytes calldata initData) external returns (address);
}
