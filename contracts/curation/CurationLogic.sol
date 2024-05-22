// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import './StorageSlot.sol';

library CurationLogic {
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
    ) internal returns (bool, uint256) {
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
