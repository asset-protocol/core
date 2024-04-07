// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {DataTypes} from '../libs/DataTypes.sol';

interface IGlobalModule {
    function onCreateAsset(
        address publisher,
        uint256 assetId,
        DataTypes.AssetCreateData calldata data
    ) external;

    function onCollect(
        uint256 assetId,
        address publiser,
        address collector,
        bytes calldata data
    ) external;

    function onUpdate(address publisher, uint256 assetId) external;
}
