// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {DataTypes} from './DataTypes.sol';

library Events {
    event AssetCreated(
        address indexed publisher,
        uint256 indexed assetId,
        string contentURI,
        address collectNFT,
        address collectModule,
        address gatedModule,
        uint256 timestamp
    );

    event AssetUpdated(uint256 indexed assetId, DataTypes.AssetUpdateData data, uint256 timestamp);

    event AssetMetadataUpdate(uint256 indexed assetId, string contentURI, uint256 timestamp);

    /**
     * @dev Emitted when a collect module is added to or removed from the whitelist.
     *
     * @param collectModule The address of the collect module.
     * @param whitelisted Whether or not the collect module is being added to the whitelist.
     * @param timestamp The current block timestamp.
     */
    event CollectModuleWhitelisted(
        address indexed collectModule,
        bool indexed whitelisted,
        uint256 timestamp
    );

    event CollectNFTTransfered(
        address indexed publiser,
        uint256 indexed assetId,
        uint256 indexed collectNFTTokenId,
        address from,
        address to,
        uint256 timestamp
    );

    event Collected(
        uint256 indexed assetId,
        address indexed collector,
        address indexed publisher,
        address collectNFT,
        uint256 collectNFTTokenId,
        address collectModule,
        bytes collectModuleData,
        uint256 timestamp
    );
}
