// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {Clones} from '@openzeppelin/contracts/proxy/Clones.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {Constants} from '../libs/Constants.sol';
import {DataTypes} from '../libs/DataTypes.sol';
import {Events} from '../libs/Events.sol';
import {ICollectNFT} from '../interfaces/ICollectNFT.sol';
import {ICollectModule} from '../interfaces/ICollectModule.sol';
import {ICreateAssetModule} from '../interfaces/ICreateAssetModule.sol';
import {IAssetGatedModule} from '../interfaces/IAssetGatedModule.sol';
import {Errors} from '../libs/Errors.sol';

library AssetHubLogic {
    error InvalidCollectNFTImpl();

    function handleAssetCreate(
        address publisher,
        uint256 assetId,
        address createAssetModule,
        address collectNFTImpl,
        DataTypes.AssetCreateData calldata data,
        mapping(uint256 => DataTypes.Asset) storage assets
    ) external {
        if (createAssetModule != address(0)) {
            ICreateAssetModule(createAssetModule).processCreate(
                publisher,
                assetId,
                data.assetCreateModuleData
            );
        }
        if (data.collectModule != address(0)) {
            ICollectModule(data.collectModule).initialModule(
                publisher,
                assetId,
                data.collectModuleInitData
            );
        }
        if (data.gatedModule != address(0)) {
            IAssetGatedModule(data.gatedModule).initialModule(
                publisher,
                assetId,
                data.gatedModuleInitData
            );
        }
        address collectNFT = _deployCollectNFT(collectNFTImpl, assetId, publisher);
        assets[assetId].collectNFT = collectNFT;
        emitAssetCreated(assetId, publisher, assets[assetId], data);
    }

    function UpdateAsset(
        uint256 assetId,
        address publiser,
        DataTypes.AssetUpdateData calldata data,
        mapping(uint256 => DataTypes.Asset) storage assets
    ) external {
        bool isUpdate = false;
        if (
            !Strings.equal(data.contentURI, '') &&
            !Strings.equal(data.contentURI, assets[assetId].contentURI)
        ) {
            isUpdate = true;
            assets[assetId].contentURI = data.contentURI;
            emit Events.MetadataUpdate(assetId);
        }
        if (data.collectModule != address(0)) {
            isUpdate = true;
            ICollectModule(data.collectModule).initialModule(
                publiser,
                assetId,
                data.collectModuleInitData
            );
            assets[assetId].collectModule = data.collectModule;
        }
        if (data.gatedModule != address(0)) {
            isUpdate = true;
            if (!IERC165(data.gatedModule).supportsInterface(type(IAssetGatedModule).interfaceId)) {
                revert Errors.InvalidGatedModule();
            }
            IAssetGatedModule(data.gatedModule).initialModule(
                publiser,
                assetId,
                data.gatedModuleInitData
            );
            assets[assetId].gatedModule = data.gatedModule;
        }
        if (isUpdate) {
            emit Events.AssetUpdated(assetId, data);
        }
    }

    function collect(
        uint256 assetId,
        address publiser,
        address collector,
        bytes calldata collectModuleData,
        mapping(uint256 => DataTypes.Asset) storage assets
    ) external returns (uint256) {
        address collectNFT = assets[assetId].collectNFT;
        address collectModule = assets[assetId].collectModule;

        if (collectModule != address(0)) {
            ICollectModule(collectModule).processCollect(
                collector,
                publiser,
                assetId,
                collectModuleData
            );
        }
        uint256 tokenId = 0;
        if (collectNFT != address(0)) {
            tokenId = ICollectNFT(collectNFT).mint(collector);
        }
        unchecked {
            assets[assetId].collectCount++;
        }
        emitCollected(
            assetId,
            collector,
            publiser,
            collectNFT,
            tokenId,
            collectModule,
            collectModuleData
        );
        return tokenId;
    }

    function _deployCollectNFT(
        address collectNFTImpl,
        uint256 assetId,
        address publisher
    ) internal returns (address) {
        if (collectNFTImpl == address(0)) {
            revert InvalidCollectNFTImpl();
        }
        address collectNFT = Clones.clone(collectNFTImpl);
        string memory collectNFTName = string.concat(
            Strings.toString(assetId),
            Constants.COLLECT_NFT_NAME_SUFFIX
        );
        string memory collectNFTSymbol = string(
            abi.encodePacked(Strings.toString(assetId), Constants.COLLECT_NFT_SYMBOL_SUFFIX)
        );
        ICollectNFT(collectNFT).initialize(collectNFTName, collectNFTSymbol, publisher, assetId);
        return collectNFT;
    }

    function emitCollected(
        uint256 assetId,
        address collector,
        address publiser,
        address collectNFT,
        uint256 tokenId,
        address collectModule,
        bytes calldata collectModuleData
    ) internal {
        emit Events.Collected(
            assetId,
            collector,
            publiser,
            collectNFT,
            tokenId,
            collectModule,
            collectModuleData,
            block.timestamp
        );
    }

    function emitAssetCreated(
        uint assetId,
        address publisher,
        DataTypes.Asset storage asset,
        DataTypes.AssetCreateData calldata data
    ) internal {
        DataTypes.AssetCreateEventData memory eventData = DataTypes.AssetCreateEventData({
            contentURI: asset.contentURI,
            assetCreateModuleData: data.assetCreateModuleData,
            collectModule: asset.collectModule,
            collectModuleInitData: data.collectModuleInitData,
            collectNFT: asset.collectNFT,
            gatedModule: asset.gatedModule,
            gatedModuleInitData: data.gatedModuleInitData
        });
        emit Events.AssetCreated(publisher, assetId, eventData);
    }
}
