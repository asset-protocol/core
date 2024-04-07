// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct AssetHubDeployData {
    address admin;
    string name;
    bool collectNft;
    address assetCreateModule;
}

interface IAssetHubManager {
    function deploy(AssetHubDeployData calldata data) external returns (address);

    function globalModule() external returns (address);
}
