// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {ERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {RequiredManagerUpgradeable} from '../management/base/RequiredManagerUpgradeable.sol';
import {ICurationGlobalModule, CurationAsset} from './Interfaces.sol';
import './StorageSlot.sol';

contract Curation is
    RequiredManagerUpgradeable,
    OwnableUpgradeable,
    ERC721Upgradeable,
    UpgradeableBase
{
    event AssetApproved(
        uint256 curationId,
        address hub,
        uint256 assetId,
        AssetApproveStatus status,
        uint256 expiry
    );
    event CurationCreated(
        address indexed publisher,
        uint256 curationId,
        string curationURI,
        uint8 status,
        uint256 expiry,
        CurationAsset[] assets
    );
    event CurationUpdated(
        uint256 indexed curationId,
        string curationURI,
        uint8 status,
        uint256 expiry
    );
    event AssetsAdded(uint256 indexed curationId, CurationAsset[] assets);
    event AssetsRemoved(uint256 indexed curationId, address[] hubs, uint256[] assetIds);

    error NotAssetPublisher(address account);

    function initialize(
        string memory name,
        string memory symbol,
        address manager
    ) external initializer {
        __Ownable_init(_msgSender());
        __ERC721_init(name, symbol);
        __RequiredManager_init(manager);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

    function version() external view virtual override returns (string memory) {
        return '0.0.4';
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        CurationStorage storage $ = StorageSlot.getCurationStorage();
        return $._curations[tokenId].tokenURI;
    }

    function create(
        string memory curationURI,
        uint8 status,
        uint256 expiry,
        CurationAsset[] calldata assets
    ) external payable virtual returns (uint256) {
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
        address publisher = _msgSender();
        uint256 tokenId = StorageSlot.createCuration(curationURI, status, expiry, assetInfos);
        if (_globalModule() != address(0)) {
            ICurationGlobalModule(_globalModule()).onCurationCreate(
                tokenId,
                publisher,
                curationURI,
                status,
                assets
            );
        }
        _mint(publisher, tokenId);
        emit CurationCreated(publisher, tokenId, curationURI, status, expiry, assets);
        return tokenId;
    }

    function approveAsset(
        uint256 id,
        address hub,
        uint256 assetId,
        AssetApproveStatus status
    ) public {
        _checkAssetOwner(hub, assetId, _msgSender());
        (bool res, uint256 expiry) = StorageSlot.approveAsset(id, hub, assetId, status);
        if (res) {
            emit AssetApproved(id, hub, assetId, status, expiry);
        }
    }

    function approveAssetBatch(
        uint256 id,
        address[] calldata hubs,
        uint256[] calldata assetIds,
        AssetApproveStatus[] calldata status
    ) external {
        for (uint i = 0; i < assetIds.length; i++) {
            approveAsset(id, hubs[i], assetIds[i], status[i]);
        }
    }

    // function curationData(uint256 curationId) external view returns (CurationData memory) {
    //     return StorageSlot.getCurationData(curationId);
    // }

    function setStatus(uint256 curationId, uint8 status) external {
        _checkTokenOwner(curationId);
        CurationStorage storage $ = StorageSlot.getCurationStorage();
        $._curations[curationId].status = status;
        emit CurationUpdated(
            curationId,
            $._curations[curationId].tokenURI,
            status,
            $._curations[curationId].expiry
        );
    }

    function setCurationURI(uint256 curationId, string memory curationURI) external {
        _checkTokenOwner(curationId);
        CurationStorage storage $ = StorageSlot.getCurationStorage();
        $._curations[curationId].tokenURI = curationURI;
        emit CurationUpdated(
            curationId,
            curationURI,
            $._curations[curationId].status,
            $._curations[curationId].expiry
        );
    }

    function setExpiry(uint256 curationId, uint64 expiry) external {
        _checkTokenOwner(curationId);
        CurationStorage storage $ = StorageSlot.getCurationStorage();
        $._curations[curationId].expiry = expiry;
        emit CurationUpdated(
            curationId,
            $._curations[curationId].tokenURI,
            $._curations[curationId].status,
            expiry
        );
    }

    function addAssets(uint256 curationId, CurationAsset[] calldata assets) external {
        _checkTokenOwner(curationId);
        for (uint i = 0; i < assets.length; i++) {
            CurationAsset memory asset = assets[i];
            _checkAssetExists(asset.hub, asset.assetId);
            StorageSlot.addAsset(
                curationId,
                AssetInfo({
                    hub: asset.hub,
                    assetId: asset.assetId,
                    expiry: 0,
                    status: AssetApproveStatus.Pending
                })
            );
        }
        emit AssetsAdded(curationId, assets);
    }

    function removeAssets(
        uint256 curationId,
        address[] calldata hubs,
        uint256[] calldata assetIds
    ) external {
        require(hubs.length == assetIds.length, 'length not match');
        for (uint i = 0; i < hubs.length; i++) {
            for (uint j = 0; j < assetIds.length; j++) {
                StorageSlot.removeAsset(curationId, hubs[i], assetIds[j]);
            }
        }
        emit AssetsRemoved(curationId, hubs, assetIds);
    }

    function assetsStatus(
        uint256 curationId,
        address[] calldata hubs,
        uint256[] calldata assetIds
    ) external view returns (AssetApproveStatus[] memory) {
        return StorageSlot.assetsStatus(curationId, hubs, assetIds);
    }

    function _checkAssetExists(address hub, uint256 assetId) internal view {
        require(IAssetHub(hub).assetPublisher(assetId) != address(0), 'asset not exists');
    }

    function _checkTokenOwner(uint256 id) internal view {
        require(_ownerOf(id) != address(0), 'curation have not created');
        require(_ownerOf(id) == _msgSender(), 'require token owner');
    }
}
