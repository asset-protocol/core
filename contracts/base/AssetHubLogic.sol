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
import {IAssetHubManager} from '../interfaces/IAssetHubManager.sol';
import {IAssetGlobalModule} from '../interfaces/IAssetGlobalModule.sol';
import {Errors} from '../libs/Errors.sol';
import {Storage, AssetNFTStorage} from './Storage.sol';

library AssetHubLogic {
    address public constant IGNORED_ADDRESS = address(1);
    bytes4 public constant ICollectModuleInterfaceId = type(ICollectModule).interfaceId;
    bytes4 public constant IGatedModuleInterfaceId = type(IAssetGatedModule).interfaceId;

    error InvalidCollectNFTImpl();

    function handleAssetCreate(
        address publisher,
        uint256 assetId,
        DataTypes.AssetCreateData calldata data
    ) external {
        mapping(address => bool) storage $collectWhitelist = Storage
            .getCollectModuleWhitelistStorage();
        if (data.collectModule != address(0)) {
            if (!$collectWhitelist[data.collectModule]) {
                revert Errors.CollectModuleNotWhitelisted();
            }
        }
        address manager = Storage.getManager();
        address globalModule = IAssetHubManager(manager).globalModule();
        if (globalModule != address(0)) {
            IAssetGlobalModule(globalModule).onCreateAsset(publisher, assetId, data);
        }
        address createAssetModule = Storage.getCreateAssetModule();
        if (createAssetModule != address(0)) {
            ICreateAssetModule(createAssetModule).processCreate(
                publisher,
                assetId,
                data.assetCreateModuleData
            );
        }
        AssetNFTStorage storage $ = Storage.getAssetStorage();
        address collectNFT = _deployCollectNFT(
            manager,
            Storage.getCollectNFTImpl(),
            assetId,
            publisher
        );
        $._assets[assetId].collectNFT = collectNFT;
        emitAssetCreated(assetId, publisher, $._assets[assetId], data);

        DataTypes.AssetUpdateData memory updateData = DataTypes.AssetUpdateData({
            collectModule: data.collectModule,
            collectModuleInitData: data.collectModuleInitData,
            gatedModule: data.gatedModule,
            gatedModuleInitData: data.gatedModuleInitData,
            contentURI: data.contentURI
        });
        _updateAsset(assetId, publisher, updateData, $._assets[assetId]);
    }

    function UpdateAsset(
        address manager,
        uint256 assetId,
        address publisher,
        DataTypes.AssetUpdateData memory data
    ) public {
        mapping(address => bool) storage $collectWhitelist = Storage
            .getCollectModuleWhitelistStorage();
        if (
            data.collectModule != address(0) && data.collectModule != AssetHubLogic.IGNORED_ADDRESS
        ) {
            if (!($collectWhitelist[data.collectModule])) {
                revert Errors.CollectModuleNotWhitelisted();
            }
        }

        AssetNFTStorage storage $ = Storage.getAssetStorage();
        DataTypes.Asset storage asset = $._assets[assetId];
        address globalModule = IAssetHubManager(manager).globalModule();
        if (globalModule != address(0)) {
            IAssetGlobalModule(globalModule).onUpdateAsset(publisher, assetId);
        }
        _updateAsset(assetId, publisher, data, asset);
    }

    function _updateAsset(
        uint256 assetId,
        address publisher,
        DataTypes.AssetUpdateData memory data,
        DataTypes.Asset storage asset
    ) public {
        bool isUpdate = false;
        if (
            !Strings.equal(data.contentURI, '') && !Strings.equal(data.contentURI, asset.contentURI)
        ) {
            isUpdate = true;
            asset.contentURI = data.contentURI;
            emit Events.MetadataUpdate(assetId);
        }

        if (data.collectModule != IGNORED_ADDRESS) {
            isUpdate = true;
            asset.collectModule = data.collectModule;
            if (data.collectModule != address(0)) {
                if (!Utils.checkSuportsInterface(data.collectModule, ICollectModuleInterfaceId)) {
                    revert Errors.InvalidCollectModule();
                }
                ICollectModule(data.collectModule).initialModule(
                    publisher,
                    assetId,
                    data.collectModuleInitData
                );
            }
        }
        if (data.gatedModule != IGNORED_ADDRESS) {
            isUpdate = true;
            asset.gatedModule = data.gatedModule;
            if (data.gatedModule != address(0)) {
                if (!Utils.checkSuportsInterface(data.gatedModule, IGatedModuleInterfaceId)) {
                    revert Errors.InvalidGatedModule();
                }
                IAssetGatedModule(data.gatedModule).initialModule(
                    publisher,
                    assetId,
                    data.gatedModuleInitData
                );
            }
        }
        if (isUpdate) {
            emitAssetUpdated(
                assetId,
                asset.contentURI,
                data.collectModule,
                data.collectModuleInitData,
                data.gatedModule,
                data.gatedModuleInitData
            );
        }
    }

    function collect(
        address manager,
        uint256 assetId,
        address publiser,
        address collector,
        bytes calldata collectModuleData
    ) external returns (uint256) {
        AssetNFTStorage storage $ = Storage.getAssetStorage();
        address collectNFT = $._assets[assetId].collectNFT;
        address collectModule = $._assets[assetId].collectModule;

        address globalModule = IAssetHubManager(manager).globalModule();
        if (globalModule != address(0)) {
            IAssetGlobalModule(globalModule).onCollectAsset(
                assetId,
                publiser,
                collector,
                collectModuleData
            );
        }

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
            $._assets[assetId].collectCount++;
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
        address manager,
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
        ICollectNFT(collectNFT).initialize(
            collectNFTName,
            collectNFTSymbol,
            manager,
            publisher,
            assetId
        );
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
        uint256 assetId,
        string memory ConentURI,
        address collectModule,
        bytes memory collectModuleInitData,
        address gatedModule,
        bytes memory gatedModuleInitData
    ) internal {
        DataTypes.AssetUpdateData memory data = DataTypes.AssetUpdateData({
            collectModule: collectModule,
            collectModuleInitData: collectModuleInitData,
            gatedModule: gatedModule,
            gatedModuleInitData: gatedModuleInitData,
            contentURI: ConentURI
        });
        emit Events.AssetUpdated(assetId, data);
    }

    function getGlobalModule(address manager) internal view returns (address) {
        return IAssetHubManager(manager).globalModule();
    }
}
