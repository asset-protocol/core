// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {Clones} from '@openzeppelin/contracts/proxy/Clones.sol';
import {Constants} from '../libs/Constants.sol';
import {DataTypes} from '../libs/DataTypes.sol';
import {Events} from '../libs/Events.sol';
import {Utils} from '../libs/Utils.sol';
import {ICollectNFT} from '../interfaces/ICollectNFT.sol';
import {ICollectModule} from '../interfaces/ICollectModule.sol';
import {ICreateAssetModule} from '../interfaces/ICreateAssetModule.sol';
import {IAssetGatedModule} from '../interfaces/IAssetGatedModule.sol';
import {Errors} from '../libs/Errors.sol';
import {console} from 'hardhat/console.sol';

library AssetHubLogic {
    address constant IGNORED_ADDRESS = address(1);
    bytes4 constant ICollectModuleInterfaceId = type(ICollectModule).interfaceId;
    bytes4 constant IGatedModuleInterfaceId = type(IAssetGatedModule).interfaceId;

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
        emitAssetUpdated(assetId, data);
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

        if (data.collectModule != IGNORED_ADDRESS) {
            isUpdate = true;
            assets[assetId].collectModule = data.collectModule;
            if (data.collectModule != address(0)) {
                if (!Utils.checkSuportsInterface(data.collectModule, ICollectModuleInterfaceId)) {
                    revert Errors.InvalidCollectModule();
                }
                ICollectModule(data.collectModule).initialModule(
                    publiser,
                    assetId,
                    data.collectModuleInitData
                );
            }
        }
        if (data.gatedModule != IGNORED_ADDRESS) {
            isUpdate = true;
            assets[assetId].gatedModule = data.gatedModule;
            if (data.gatedModule != address(0)) {
                if (!Utils.checkSuportsInterface(data.gatedModule, IGatedModuleInterfaceId)) {
                    revert Errors.InvalidGatedModule();
                }
                IAssetGatedModule(data.gatedModule).initialModule(
                    publiser,
                    assetId,
                    data.gatedModuleInitData
                );
            }
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
            ICollectModule(collectModule).processCollect{value: msg.value}(
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
        emit Events.AssetCreated(assetId, publisher, asset.collectNFT, data.assetCreateModuleData);
    }

    function emitAssetUpdated(
        uint assetId,
        DataTypes.AssetCreateData calldata createData
    ) internal {
        DataTypes.AssetUpdateData memory data = DataTypes.AssetUpdateData({
            collectModule: createData.collectModule,
            collectModuleInitData: createData.collectModuleInitData,
            gatedModule: createData.gatedModule,
            gatedModuleInitData: createData.gatedModuleInitData,
            contentURI: createData.contentURI
        });
        emit Events.AssetUpdated(assetId, data);
    }
}
