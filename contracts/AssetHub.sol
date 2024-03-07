// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {UpgradeableBase} from './upgradeability/UpgradeableBase.sol';
import {IAssetHub} from './interfaces/IAssetHub.sol';
import {ICollectNFT} from './interfaces/ICollectNFT.sol';
import {ICreateAssetModule} from './interfaces/ICreateAssetModule.sol';
import {IAssetGatedModule} from './interfaces/IAssetGatedModule.sol';
import {AssetNFTBase} from './base/AssetNFTBase.sol';
import {AssetHubLogic} from './base/AssetHubLogic.sol';
import {Events} from './libs/Events.sol';
import {Errors} from './libs/Errors.sol';
import {Constants} from './libs/Constants.sol';
import {DataTypes} from './libs/DataTypes.sol';

contract AssetHub is AssetNFTBase, OwnableUpgradeable, UpgradeableBase, IAssetHub {
    string private constant VERSION = '1.0.0';
    address private _collectNFTImpl;
    address private _createAssetModule;
    mapping(address => bool) private _collectModuleWhitelisted;

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

    function version() external virtual override returns (string memory) {
        return VERSION;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function transferHubOwnership(address newOwner) external {
        transferOwnership(newOwner);
    }

    function hubOwner() public view override returns (address) {
        return owner();
    }

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
            sender = hubOwner(); // use owner as the sender
        } else {
            pub = _msgSender();
            sender = pub;
        }
        uint256 res = _createAsset(pub, data);
        AssetHubLogic.handleAssetCreate(
            pub,
            res,
            _createAssetModule,
            _collectNFTImpl,
            data,
            _assets
        );
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
            if (!IERC165(assetModule).supportsInterface(type(ICreateAssetModule).interfaceId)) {
                revert Errors.InvalidCreateAssetModule();
            }
        }
        _createAssetModule = assetModule;
    }

    function assetPublisher(uint256 assetId) external view returns (address) {
        return ownerOf(assetId);
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
        address collectModule = _assets[assetId].collectModule;
        if (collectModule != address(0)) {
            if (!_collectModuleWhitelisted[collectModule]) {
                revert Errors.CollectModuleNotWhitelisted();
            }
        }
        address collector = _msgSender();
        return
            AssetHubLogic.collect(
                assetId,
                _ownerOf(assetId),
                collector,
                collectModuleData,
                _assets
            );
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
        if (_msgSender() != expectedCollectNFT) revert Errors.CallerNotCollectNFT();
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

    function _setGatedModule(uint256 assetId, address gatedModule) internal {
        if (gatedModule != address(0)) {
            if (!IERC165(gatedModule).supportsInterface(type(IAssetGatedModule).interfaceId)) {
                revert Errors.InvalidGatedModule();
            }
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
}
