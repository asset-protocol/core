// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {DataTypes} from '../libs/DataTypes.sol';

interface IAssetGlobalModule {
    function onCreateAsset(
        address publisher,
        uint256 assetId,
        DataTypes.AssetCreateData calldata data
    ) external payable;

    function onCollectAsset(
        uint256 assetId,
        address publiser,
        address collector,
        bytes calldata data
    ) external payable;

    function onUpdateAsset(address publisher, uint256 assetId) external payable;
}
