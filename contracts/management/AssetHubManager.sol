// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';
import {WhitelistBase} from '../base/WhitlistBase.sol';
import {IModuleFactory, IAssetHubFactory} from './IFactory.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';

struct AssetHubInfo {
    address collectNFT;
    address nftGatedModule;
    address assetCreateModule;
    address tokenCollectModule;
    address feeCollectModule;
}

struct AssetHubDeployData {
    address admin;
    string name;
    bool collectNft;
    address assetCreateModule;
}

struct AssetHubImplData {
    address assetHubFactory;
    address tokenCollectModuleFactory;
    address nftGatedModuleFactory;
    address tokenAssetCreateModuleFactory;
    address collectNFTFactory;
    address feeCollectModuleFactory;
}

contract AssetHubManager is OwnableUpgradeable, UpgradeableBase, WhitelistBase {
    AssetHubImplData internal _implData;
    mapping(string => address) private _namedHubs;
    mapping(address => AssetHubInfo) private _assetHubs;

    event AssetHubDeployed(address indexed admin, string name, address assetHub, AssetHubInfo data);

    error NameHubExisted(string hubName);
    error AssetHubNotExisted();

    function initialize(AssetHubImplData calldata data) external initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __AssetHubManager_init(data);
        _setWhitelist(_msgSender(), true);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function __AssetHubManager_init(AssetHubImplData calldata data) internal onlyInitializing {
        _implData = data;
    }

    function setWhitelist(address account, bool whitelist) external onlyOwner {
        _setWhitelist(account, whitelist);
    }

    function assetHubInfo(address hub) external view returns (AssetHubInfo memory) {
        return _assetHubs[hub];
    }

    function assetHubInfoByName(string calldata name) external view returns (AssetHubInfo memory) {
        address hub = _namedHubs[name];
        return _assetHubs[hub];
    }

    function factories() external view returns (AssetHubImplData memory) {
        return _implData;
    }

    function setFactories(AssetHubImplData calldata data) external {
        if (data.assetHubFactory != address(0)) {
            _implData.assetHubFactory = data.assetHubFactory;
        }
        if (data.tokenCollectModuleFactory != address(0)) {
            _implData.tokenCollectModuleFactory = data.tokenCollectModuleFactory;
        }
        if (data.nftGatedModuleFactory != address(0)) {
            _implData.nftGatedModuleFactory = data.nftGatedModuleFactory;
        }
        if (data.tokenAssetCreateModuleFactory != address(0)) {
            _implData.tokenAssetCreateModuleFactory = data.tokenAssetCreateModuleFactory;
        }
    }

    function exitsName(string calldata name) public view returns (bool) {
        return _namedHubs[name] != address(0);
    }

    function deploy(AssetHubDeployData calldata data) external returns (address) {
        _checkWhitelisted(_msgSender());
        if (_implData.assetHubFactory == address(0)) {
            revert('AssetHubFactory: not initialized');
        }
        if (exitsName(data.name)) {
            revert NameHubExisted(data.name);
        }
        return _deployHub(data);
    }

    function createHubImpl(bytes calldata initData) external returns (address hubImpl) {
        address newHubImpl = IAssetHubFactory(_implData.assetHubFactory).create(initData);
        return newHubImpl;
    }

    function createTokenCollectModuleImpl(
        address hub,
        bytes calldata initData
    ) external returns (address) {
        return IModuleFactory(_implData.tokenCollectModuleFactory).create(hub, initData);
    }

    function createNftAssetGatedModuleImpl(
        address hub,
        bytes calldata initData
    ) external returns (address) {
        return IModuleFactory(_implData.nftGatedModuleFactory).create(hub, initData);
    }

    function createFeeCollectModuleImpl(
        address hub,
        bytes calldata initData
    ) external returns (address) {
        return IModuleFactory(_implData.feeCollectModuleFactory).create(hub, initData);
    }

    function createTokenAssetCreateModule(
        address hub,
        bytes calldata initData
    ) external returns (address) {
        return IModuleFactory(_implData.tokenAssetCreateModuleFactory).create(hub, initData);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _deployHub(AssetHubDeployData calldata data) internal returns (address) {
        address admin = data.admin;
        if (admin == address(0)) {
            admin = _msgSender();
        }
        address assetHub = IAssetHubFactory(_implData.assetHubFactory).createUUPSUpgradeable('');

        AssetHubInfo memory info = AssetHubInfo({
            tokenCollectModule: _deployUUPSUpgradeableModule(
                assetHub,
                _implData.tokenCollectModuleFactory
            ),
            nftGatedModule: _deployUUPSUpgradeableModule(assetHub, _implData.nftGatedModuleFactory),
            feeCollectModule: _deployUUPSUpgradeableModule(
                assetHub,
                _implData.feeCollectModuleFactory
            ),
            assetCreateModule: data.assetCreateModule,
            collectNFT: _deployUUPSUpgradeableModule(assetHub, _implData.collectNFTFactory)
        });
        _assetHubs[assetHub] = info;
        _namedHubs[data.name] = assetHub;
        address[] memory collectModule = new address[](2);
        collectModule[0] = info.tokenCollectModule;
        collectModule[1] = info.feeCollectModule;
        IAssetHub(assetHub).initialize(
            data.name,
            data.name,
            admin,
            info.collectNFT,
            data.assetCreateModule,
            collectModule
        );

        emit AssetHubDeployed(admin, data.name, assetHub, info);
        return assetHub;
    }

    function _deployUUPSUpgradeableModule(address hub, address factory) internal returns (address) {
        return IModuleFactory(factory).createUUPSUpgradeable(hub, new bytes(0));
    }
}
