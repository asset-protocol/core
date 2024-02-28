// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {UUPSUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import {Clones} from '@openzeppelin/contracts/proxy/Clones.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {ICollectNFT} from '../interfaces/ICollectNFT.sol';
import {ICollectModule} from '../interfaces/ICollectModule.sol';
import {ICreateAssetModule} from '../interfaces/ICreateAssetModule.sol';
import {IAssetGatedModule} from '../interfaces/IAssetGatedModule.sol';
import {AssetNFTBase} from '../base/AssetNFTBase.sol';
import {Events} from '../libs/Events.sol';
import {Errors} from '../libs/Errors.sol';
import {Constants} from '../libs/Constants.sol';
import {DataTypes} from '../libs/DataTypes.sol';

contract AssetHub is AssetNFTBase, OwnableUpgradeable, UUPSUpgradeable, IAssetHub {
    address private _collectNFTImpl;
    address private _createAssetModule;
    mapping(address => bool) private _collectModuleWhitelisted;

    error InvalidCollectNFTImpl();

    function initialize(
        string memory name,
        string memory symbol,
        address admin,
        address collectNFT,
        address createAssetModule
    ) external initializer {
        __AssetNFTBase_init(name, symbol);
        __Ownable_init(admin);
        __UUPSUpgradeable_init();
        _collectNFTImpl = collectNFT;
        _createAssetModule = createAssetModule;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function create(
        DataTypes.AssetCreateData calldata data
    ) external override(IAssetHub) whenNotPaused returns (uint256) {
        if (data.collectModule != address(0)) {
            if (!_collectModuleWhitelisted[data.collectModule]) {
                revert Errors.CollectModuleNotWhitelisted();
            }
        }

        address pub = data.publisher;
        address sender = address(0);
        if (pub != address(0)) {
            _checkOwner();
            sender = owner(); // use owner as the sender
        } else {
            pub = _msgSender();
            sender = pub;
        }
        uint256 res = _createAsset(pub, data);

        if (_createAssetModule != address(0)) {
            ICreateAssetModule(_createAssetModule).processCreate(pub, res, data.assetCreateModuleData);
        }

        if (data.collectModule != address(0)) {
            ICollectModule(data.collectModule).initialModule(pub, res, data.collectModuleInitData);
        }

        if (data.gatedModule != address(0)) {
            IAssetGatedModule(data.gatedModule).initialModule(pub, res, data.gatedModuleInitData);
        }

        address collectNFT = _deployCollectNFT(res, pub);
        _assets[res].collectNFT = collectNFT;

        _emitAssetCreated(res, pub, _assets[res]);
        return res;
    }

    function update(
        uint256 assetId,
        DataTypes.AssetUpdateData calldata data
    ) external whenNotPaused {
        _requireAssetPublisher(assetId, _msgSender());
        _setCollectModule(assetId, data.collectModule);
        _setGatedModule(assetId, data.gatedModule);
        emit Events.AssetUpdated(assetId, data, block.timestamp);
    }

    function setCreateAssetModule(address assetModule) external onlyOwner {
        if (_createAssetModule != address(0)) {
            require(
                IERC165(assetModule).supportsInterface(type(ICreateAssetModule).interfaceId),
                'Invalid create asset module(ICreateAssetModule)'
            );
        }
        _createAssetModule = assetModule;
    }

    function getCreateAssetModule() external view returns (address) {
        return _createAssetModule;
    }

    function assetGated(uint256 assetId, address account) external view returns (bool) {
        address gatedModule = _assets[assetId].gatedModule;
        if (gatedModule == address(0)) {
            return true;
        }
        return IAssetGatedModule(gatedModule).isGated(assetId, account);
    }

    function collectModuleWhitelist(
        address collectModule,
        bool whitelist
    ) external whenNotPaused onlyOwner {
        _collectModuleWhitelisted[collectModule] = whitelist;
        emit Events.CollectModuleWhitelisted(collectModule, whitelist, block.timestamp);
    }

    function isCollectModuleWhitelisted(address followModule) external view returns (bool) {
        return _collectModuleWhitelisted[followModule];
    }

    function collect(
        uint256 assetId,
        bytes calldata collectModuleData
    ) external override whenNotPaused returns (uint256) {
        _checkAssetId(assetId);
        address collectNFT = _assets[assetId].collectNFT;
        address collectModule = _assets[assetId].collectModule;

        address collector = _msgSender();

        if (collectModule != address(0)) {
            if (!_collectModuleWhitelisted[collectModule]) {
                revert Errors.CollectModuleNotWhitelisted();
            }
            ICollectModule(collectModule).processCollect(
                collector,
                ownerOf(assetId),
                assetId,
                collectModuleData
            );
        }
        uint256 tokenId = 0;
        if (collectNFT != address(0)) {
            tokenId = ICollectNFT(collectNFT).mint(collector);
        }
        _assets[assetId].collectCount++;
        emit Events.Collected(
            assetId,
            collector,
            ownerOf(assetId),
            collectNFT,
            tokenId,
            collectModule,
            collectModuleData,
            block.timestamp
        );
        return tokenId;
    }

    function assetCollectCount(uint256 assetId) external view returns (uint256) {
        return _assets[assetId].collectCount;
    }

    function assetCollectNFT(uint256 assetId) external view returns (address) {
        return _assets[assetId].collectNFT;
    }

    function userCollectCount(uint256 assetId, address collector) external view returns (uint256) {
        if (collector == address(0)) {
            return 0;
        }
        address collectNFT = _assets[assetId].collectNFT;
        if (collectNFT == address(0)) {
            return 0;
        }
        return ICollectNFT(collectNFT).count(collector);
    }

    function emitCollectNFTTransferEvent(
        address publiser,
        uint256 assetId,
        uint256 collectNFTId,
        address from,
        address to
    ) external override {
        address expectedCollectNFT = _assets[assetId].collectNFT;
        if (msg.sender != expectedCollectNFT) revert Errors.CallerNotCollectNFT();
        emit Events.CollectNFTTransfered(
            publiser,
            assetId,
            collectNFTId,
            from,
            to,
            block.timestamp
        );
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(AssetNFTBase) returns (bool) {
        return interfaceId == type(IAssetHub).interfaceId || super.supportsInterface(interfaceId);
    }

    function _deployCollectNFT(uint256 assetId, address publisher) private returns (address) {
        if (_collectNFTImpl == address(0)) {
            revert InvalidCollectNFTImpl();
        }
        address collectNFT = Clones.clone(_collectNFTImpl);
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

    function _setGatedModule(uint256 assetId, address gatedModule) internal {
        if (gatedModule != address(0)) {
            require(
                IERC165(gatedModule).supportsInterface(type(IAssetGatedModule).interfaceId),
                'Invalid gated module(IAssetGatedModule)'
            );
        }
        _assets[assetId].gatedModule = gatedModule;
    }

    function _setCollectModule(uint256 assetId, address collectModule) internal {
        if (collectModule != address(0)) {
            if (!_collectModuleWhitelisted[collectModule]) {
                revert Errors.CollectModuleNotWhitelisted();
            }
        }
        _assets[assetId].collectModule = collectModule;
    }

    function _emitAssetCreated(
        uint assetId,
        address publisher,
        DataTypes.Asset memory asset
    ) internal {
        DataTypes.AssetCreatedEventData memory eventData = DataTypes.AssetCreatedEventData({
            contentURI: asset.contentURI,
            collectNFT: asset.collectNFT,
            collectModule: asset.collectModule,
            gatedModule: asset.gatedModule
        });
        emit Events.AssetCreated(publisher, assetId, asset.timestamp, eventData);
    }
}
