// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct CurationAsset {
    address hub;
    uint256 assetId;
    uint order;
}

interface ICurationGlobalModule {
    function onCurationCreate(
        uint256 curationId,
        address publisher,
        string memory curationURI,
        uint8 status,
        CurationAsset[] calldata assets
    ) external payable;

    function onCurationCollect(
        uint256 curationId,
        address publiser,
        address collector,
        bytes calldata data
    ) external;
}
