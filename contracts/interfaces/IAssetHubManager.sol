// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct HubCreateData {
    address admin;
    string name;
    address createModule;
}

struct LiteHubInfo {
    address createModule;
    address tokenCollectModule;
    address feeCollectModule;
    address nftGatedModule;
}

interface IAssetHubManagerEvents {
    event AssetHubDeployed(address indexed admin, string name, address assetHub, LiteHubInfo data);
    event GlobalModuleChanged(address globalModule);
    event HubCreatorNFTChanged(address creatorNFT);
    event CurationUpdated(address curation);
}

interface IAssetHubManager is IAssetHubManagerEvents {
    function deploy(HubCreateData calldata data) external returns (address);

    function globalModule() external view returns (address);

    function isHub(address hub) external view returns (bool);

    function curation() external view returns (address);
}
