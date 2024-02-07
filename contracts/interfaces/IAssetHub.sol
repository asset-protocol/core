// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DataTypes} from '../libs/DataTypes.sol';
import {IERC721Metadata} from '@openzeppelin/contracts/interfaces/IERC721Metadata.sol';

interface IAssetHub is IERC721Metadata {
    /// @notice create a new asset
    /// @param data the data of the asset
    /// @return the id of the asset
    function create(DataTypes.CreateAssetData calldata data) external returns (uint256);

    /// @notice subscribe to an asset
    /// @param assetId the id of the asset
    /// @param data the data of the subscription
    function subscribe(uint256 assetId, bytes calldata data) external returns (uint256);

    function emitSubscribeNFTTransferEvent(
        address publiser,
        uint256 assetId,
        uint256 tokenId,
        address from,
        address to
    ) external;

    function getTokenTransfer() external view returns (address);
}
