// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct HubCreateData {
    address admin;
    string name;
    address createModule;
}

interface IAssetHubManager {
    function deploy(HubCreateData calldata data) external returns (address);

    function globalModule() external returns (address);

    function isHub(address hub) external view returns (bool);
}
