// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct AssetInfo {
    address hub;
    uint256 assetId;
    uint order;
    AssetApproveStatus status;
}

struct CurationData {
    AssetInfo[] assets;
    string tokenURI;
    uint8 status;
}

enum AssetApproveStatus {
    Pending,
    Approved,
    Rejected
}

struct CurationStorage {
    uint256 _tokenCounter;
    mapping(uint256 tokenId => CurationData) _curations;
}

library StorageSlot {
    // keccak256(abi.encode(uint256(keccak256('curation.storage.info')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 internal constant CurationStorageLocation =
        0x630988ce46de1e9d40f4a157e51f63ecc4f010353c5635d4c643ce648b328c00;

    function getCurationStorage() internal pure returns (CurationStorage storage $) {
        assembly {
            $.slot := CurationStorageLocation
        }
    }

    function approveAsset(
        uint256 id,
        address hub,
        uint256 assetId,
        AssetApproveStatus status
    ) internal {
        CurationStorage storage $ = getCurationStorage();
        AssetInfo[] storage assets = $._curations[id].assets;
        for (uint i = 0; i < assets.length; i++) {
            if (assets[i].assetId == assetId && assets[i].hub == hub) {
                assets[i].status = status;
            }
        }
    }

    function getCurationData(uint256 assetId) internal view returns (CurationData storage) {
        CurationStorage storage $ = getCurationStorage();
        return $._curations[assetId];
    }

    function createCuration(
        string memory curationURI,
        uint8 status,
        AssetInfo[] memory assets
    ) internal returns (uint256) {
        CurationStorage storage $ = getCurationStorage();
        uint256 tokenId = $._tokenCounter;
        CurationData storage curation = $._curations[tokenId];
        curation.tokenURI = curationURI;
        curation.status = status;
        for (uint i = 0; i < assets.length; i++) {
            curation.assets.push(assets[i]);
        }
        unchecked {
            $._tokenCounter = tokenId + 1;
        }
        return tokenId;
    }

    function addAsset(uint256 id, AssetInfo memory asset) internal {
        CurationStorage storage $ = getCurationStorage();
        CurationData storage curation = $._curations[id];
        require(asset.hub != address(0), 'Invalid hub address');
        curation.assets.push(asset);
    }

    function removeAsset(uint256 id, address hub, uint256 assetId) internal {
        CurationStorage storage $ = getCurationStorage();
        CurationData storage curation = $._curations[id];
        for (uint j = 0; j < curation.assets.length; j++) {
            if (curation.assets[j].hub == hub && curation.assets[j].assetId == assetId) {
                curation.assets[j] = curation.assets[curation.assets.length - 1];
                curation.assets.pop();
                break;
            }
        }
    }
}
