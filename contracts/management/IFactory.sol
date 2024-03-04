// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IAssetHubFactory {
    error NotImplemented();

    function create(bytes calldata initData) external returns (address);
}

interface IModuleFactory {
    error NotImplemented();

    function create(address hub, bytes calldata initData) external returns (address);
}

interface IUUPSUpgradeable {
    function upgradeToAndCall(address newImplementation, bytes memory data) external;
}
