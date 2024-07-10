// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './StorageSlot.sol';
import {ICurationGlobalModule, CurationAsset} from './Interfaces.sol';

library CurationLogic {
    function create(
        address publisher,
        address globalModule,
        address hub,
        string memory curationURI,
        uint8 status,
        uint256 expiry,
        CurationAsset[] calldata assets
    ) external returns (uint256) {
        AssetInfo[] memory assetInfos = new AssetInfo[](assets.length);
        for (uint i = 0; i < assets.length; i++) {
            CurationAsset memory asset = assets[i];
            assetInfos[i] = AssetInfo({
                hub: asset.hub,
                assetId: asset.assetId,
                status: AssetApproveStatus.Pending,
                expiry: 0
            });
        }
        uint256 tokenId = StorageSlot.createCuration(curationURI, status, expiry, assetInfos);
        if (globalModule != address(0)) {
            ICurationGlobalModule(globalModule).onCurationCreate(
                publisher,
                tokenId,
                hub,
                curationURI,
                status,
                assets
            );
        }
        return tokenId;
    }

    function assetsStatus(
        uint256 curationId,
        address[] calldata hubs,
        uint256[] calldata assetIds
    ) external view returns (AssetApproveStatus[] memory) {
        CurationStorage storage $ = StorageSlot.getCurationStorage();
        AssetInfo[] storage assets = $._curations[curationId].assets;
        if (assets.length == 0 || hubs.length == 0) {
            return new AssetApproveStatus[](0);
        }
        require(hubs.length == assetIds.length, 'length not match');
        AssetApproveStatus[] memory result = new AssetApproveStatus[](hubs.length);
        for (uint i = 0; i < hubs.length; i++) {
            for (uint j = 0; j < assets.length; j++) {
                if (assets[j].hub == hubs[i] && assets[j].assetId == assetIds[i]) {
                    if (
                        assets[j].status == AssetApproveStatus.Approved &&
                        assets[j].expiry != 0 &&
                        assets[j].expiry < block.timestamp
                    ) {
                        result[i] = AssetApproveStatus.Expired;
                    } else {
                        result[i] = assets[j].status;
                    }
                    break;
                }
            }
        }
        return result;
    }

    function approveAsset(
        uint256 id,
        address hub,
        uint256 assetId,
        AssetApproveStatus status
    ) external returns (bool, uint256) {
        CurationStorage storage $ = StorageSlot.getCurationStorage();
        AssetInfo[] storage assets = $._curations[id].assets;
        uint256 expiry = 0;
        for (uint i = 0; i < assets.length; i++) {
            if (assets[i].assetId == assetId && assets[i].hub == hub) {
                assets[i].status = status;
                if (status == AssetApproveStatus.Approved) {
                    assets[i].expiry = $._curations[id].expiry;
                    expiry = $._curations[id].expiry;
                } else {
                    assets[i].expiry = 0;
                }
                return (true, expiry);
            }
        }
        return (false, expiry);
    }
}
