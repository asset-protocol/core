// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {UpgradeableBase} from './upgradeability/UpgradeableBase.sol';
import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import {IAssetHub} from './interfaces/IAssetHub.sol';
import {ICollectNFT} from './interfaces/ICollectNFT.sol';
import {ICreateAssetModule} from './interfaces/ICreateAssetModule.sol';
import {IAssetGatedModule} from './interfaces/IAssetGatedModule.sol';
import {ERC7572} from './base/ERC7572.sol';
import {AssetNFTBase} from './base/AssetNFTBase.sol';
import {AssetHubLogic} from './base/AssetHubLogic.sol';
import {Storage, AssetNFTStorage} from './base/Storage.sol';
import {Events} from './libs/Events.sol';
import {Errors} from './libs/Errors.sol';
import {Constants} from './libs/Constants.sol';
import {DataTypes} from './libs/DataTypes.sol';

contract AssetHub is AssetNFTBase, OwnableUpgradeable, UpgradeableBase, ERC7572, IAssetHub {
    function initialize(
        string memory name,
        address manager,
        address admin,
        address collectNFT,
        address createAssetModule,
        address[] memory whitelistedCollectModules,
        string memory contractURI
    ) external initializer {
        __AssetNFTBase_init(name, name);
        __Ownable_init(admin);
        __UUPSUpgradeable_init();
        Storage.setCollectNFTImpl(collectNFT);
        Storage.setCreateAssetModule(createAssetModule);
        Storage.setManager(manager);
        for (uint i = 0; i < whitelistedCollectModules.length; i++) {
            if (whitelistedCollectModules[i] != address(0)) {
                _setCollectModuleWhitelist(whitelistedCollectModules[i], true);
            }
        }
        _setContractURI(contractURI);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function version() external view virtual override returns (string memory) {
        return '0.2.2';
    }

    function hubOwner() public view override returns (address) {
        return owner();
    }

    function globalModule() external view returns (address) {
        return AssetHubLogic.getGlobalModule(Storage.getManager());
    }

    function create(
        DataTypes.AssetCreateData calldata data
    ) external payable override(IAssetHub) whenNotPaused returns (uint256) {
        address pub = data.publisher;
        if (pub == address(0)) {
            pub = _msgSender();
        }
        uint256 res = _createAsset(pub, data);
        AssetHubLogic.handleAssetCreate(pub, res, data);
        return res;
    }

    function update(
        uint256 assetId,
        DataTypes.AssetUpdateData calldata data
    ) external payable whenNotPaused {
        _requireAssetPublisher(assetId, _msgSender());
        AssetHubLogic.UpdateAsset(Storage.getManager(), assetId, _ownerOf(assetId), data);
    }

    function setCreateAssetModule(address assetModule) external onlyOwner {
        if (assetModule != address(0)) {
            if (!IERC165(assetModule).supportsInterface(type(ICreateAssetModule).interfaceId)) {
                revert Errors.InvalidCreateAssetModule();
            }
        }
        Storage.setCreateAssetModule(assetModule);
    }

    function assetPublisher(uint256 assetId) external view returns (address) {
        return _ownerOf(assetId);
    }

    function getCreateAssetModule() external view returns (address) {
        return Storage.getCreateAssetModule();
    }

    function setContractURI(string memory uri) external onlyOwner {
        _setContractURI(uri);
        emit InfoURIChanged(uri);
    }

    function setIsOpen(bool isOpen) external onlyOwner {
        Storage.setIsOpen(isOpen);
        emit IsOpenChanged(isOpen);
    }

    function assetGated(uint256 assetId, address account) external view returns (bool) {
        AssetNFTStorage storage $ = Storage.getAssetStorage();
        address gatedModule = $._assets[assetId].gatedModule;
        if (gatedModule == address(0)) {
            return true;
        }
        return IAssetGatedModule(gatedModule).isGated(assetId, account);
    }

    function setCollectModuleWhitelist(
        address collectModule,
        bool whitelist
    ) external whenNotPaused onlyOwner {
        _setCollectModuleWhitelist(collectModule, whitelist);
    }

    function _setCollectModuleWhitelist(address collectModule, bool whitelist) internal {
        mapping(address => bool) storage $ = Storage.getCollectModuleWhitelistStorage();
        $[collectModule] = whitelist;
        emit Events.CollectModuleWhitelisted(collectModule, whitelist, block.timestamp);
    }

    function collectModuleWhitelisted(address followModule) public view returns (bool) {
        mapping(address => bool) storage $ = Storage.getCollectModuleWhitelistStorage();
        return $[followModule];
    }

    function collect(
        uint256 assetId,
        bytes calldata collectModuleData
    ) external payable override whenNotPaused returns (uint256) {
        _checkAssetId(assetId);
        address collector = _msgSender();
        return
            AssetHubLogic.collect(
                Storage.getManager(),
                assetId,
                _ownerOf(assetId),
                collector,
                collectModuleData
            );
    }

    function assetCollectCount(uint256 assetId) external view returns (uint256) {
        AssetNFTStorage storage $ = Storage.getAssetStorage();
        return $._assets[assetId].collectCount;
    }

    function assetCollectNFT(uint256 assetId) external view returns (address) {
        AssetNFTStorage storage $ = Storage.getAssetStorage();
        return $._assets[assetId].collectNFT;
    }

    function userCollectCount(uint256 assetId, address collector) external view returns (uint256) {
        if (collector == address(0)) {
            return 0;
        }
        AssetNFTStorage storage $ = Storage.getAssetStorage();
        address collectNFT = $._assets[assetId].collectNFT;
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
        AssetNFTStorage storage $ = Storage.getAssetStorage();
        address expectedCollectNFT = $._assets[assetId].collectNFT;
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
}
