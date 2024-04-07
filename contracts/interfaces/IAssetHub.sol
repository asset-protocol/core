// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DataTypes} from '../libs/DataTypes.sol';

interface IAssetHub {
    function initialize(
        string memory name,
        address manager,
        address admin,
        address collectNFT,
        address createAssetModule,
        address[] memory whitelistedCollectModules
    ) external;

    /// @notice create a new asset
    /// @param data the data of the asset
    /// @return the id of the asset
    function create(DataTypes.AssetCreateData calldata data) external returns (uint256);

    /// @notice collect to an asset
    /// @param assetId the id of the asset
    /// @param data the data of the subscription
    function collect(uint256 assetId, bytes calldata data) external payable returns (uint256);

    function emitCollectNFTTransferEvent(
        address publiser,
        uint256 assetId,
        uint256 tokenId,
        address from,
        address to
    ) external;

    function hubOwner() external view returns (address);

    function assetPublisher(uint256 assetId) external view returns (address);
}
