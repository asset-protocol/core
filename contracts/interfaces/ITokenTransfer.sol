// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenTransfer {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}