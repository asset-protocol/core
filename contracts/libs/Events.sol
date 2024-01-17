// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library Events {
    event AssetCreated(
        uint256 indexed publisher,
        uint256 indexed assetId,
        string contentURI,
        address collectModule,
        bytes collectModuleReturnData,
        address referenceModule,
        bytes referenceModuleReturnData,
        uint256 timestamp
    );

    /**
     * @dev Emitted when a subscribe module is added to or removed from the whitelist.
     *
     * @param subscribeModule The address of the subscribe module.
     * @param whitelisted Whether or not the subscribe module is being added to the whitelist.
     * @param timestamp The current block timestamp.
     */
    event SubscribeModuleWhitelisted(
        address indexed subscribeModule,
        bool indexed whitelisted,
        uint256 timestamp
    );

    event SubscribeNFTDeployed(
        uint256 indexed assetId,
        address indexed subscribeNFT,
        uint256 timestamp
    );

    event SubscribeNFTTransferred(
        address indexed publiser,
        uint256 indexed assetId,
        uint256 indexed subscribeNFTId,
        address from,
        address to,
        uint256 timestamp
    );

    event Subscribed(
        address indexed subscriber,
        address indexed publiser,
        uint256 indexed assetId,
        bytes collectModuleData,
        uint256 timestamp
    );
}
