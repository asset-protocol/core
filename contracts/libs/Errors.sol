// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library Errors {
    error InitParamsInvalid();
    error NoAssetPublisher();
    error NotAssetPublisher();
    error NotHub();
    error Initialized();
    error TokenDoesNotExist();
    error AssetDoesNotExist();
    error CallerNotCollectNFT();
    error CollectModuleNotWhitelisted();
    error InvalidCreateAssetModule();
    error InvalidGatedModule();
    error InvalidCollectModule();
    error InvalidModule();
}
