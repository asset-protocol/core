// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenWallet {
    function deposit(uint256 amount) external;

    function withdraw(uint256 amount) external;

    function withdrawAll() external;

    function balanceOf(address account) external view returns (uint256);

    function verifyErc20Currency(address currency) external returns (bool);
}
