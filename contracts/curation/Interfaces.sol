// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct CurationAsset {
    address hub;
    uint256 assetId;
}

interface ICurationGlobalModule {
    function onCurationCreate(
        address publisher,
        uint256 curationId,
        address hub,
        string memory curationURI,
        uint8 status,
        CurationAsset[] calldata assets
    ) external payable;

    function onCurationCollect(
        address publiser,
        uint256 curationId,
        address hub,
        address collector,
        bytes calldata data
    ) external;
}
