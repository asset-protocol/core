// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';
import {WhitelistBase} from '../base/WhitlistBase.sol';
import {IModuleFactory, IAssetHubFactory} from './IFactory.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';

struct AssetHubInfo {
    address assetHub;
    address feeCollectModule;
    address nftGatedModule;
    address assetCreateModule;
    address collectNFT;
}

struct AssetHubDeployData {
    address admin;
    string name;
    bool collectNft;
    address assetCreateModule;
}

struct AssetHubImplData {
    address assetHubFactory;
    address feeCollectModuleFactory;
    address nftGatedModuleFactory;
    address feeCreateAssetModuleFactory;
    address collectNFTFactory;
}

contract AssetHubManager is OwnableUpgradeable, UpgradeableBase, WhitelistBase {
    AssetHubImplData internal _implData;
    mapping(string => address) private _namedHubs;
    mapping(address => AssetHubInfo) private _assetHubs;

    event AssetHubDeployed(
        address indexed admin,
        string name,
        address assetHub,
        address feeCollectModule,
        address nftGatedModule,
        address assetCreateModule
    );

    error NameHubExisted(string hubName);
    error AssetHubNotExisted();

    function initialize(AssetHubImplData calldata data) external initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __AssetHubFactory_init(data);
        _setWhitelist(_msgSender(), true);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function __AssetHubFactory_init(AssetHubImplData calldata data) internal onlyInitializing {
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
        if (data.feeCollectModuleFactory != address(0)) {
            _implData.feeCollectModuleFactory = data.feeCollectModuleFactory;
        }
        if (data.nftGatedModuleFactory != address(0)) {
            _implData.nftGatedModuleFactory = data.nftGatedModuleFactory;
        }
        if (data.feeCreateAssetModuleFactory != address(0)) {
            _implData.feeCreateAssetModuleFactory = data.feeCreateAssetModuleFactory;
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
        _checkWhitelisted(_msgSender());
        address newHubImpl = IAssetHubFactory(_implData.assetHubFactory).create(initData);
        return newHubImpl;
    }

    function createFeeCollectModuleImpl(
        address hub,
        bytes calldata initData
    ) external returns (address) {
        _checkWhitelisted(_msgSender());
        return IModuleFactory(_implData.feeCollectModuleFactory).create(hub, initData);
    }

    function createNftAssetGatedModuleImpl(
        address hub,
        bytes calldata initData
    ) external returns (address) {
        _checkWhitelisted(_msgSender());
        return IModuleFactory(_implData.nftGatedModuleFactory).create(hub, initData);
    }

    function createFeeAssetCreateModule(
        address hub,
        bytes calldata initData
    ) external returns (address) {
        _checkWhitelisted(_msgSender());
        return IModuleFactory(_implData.feeCreateAssetModuleFactory).create(hub, initData);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _deployHub(AssetHubDeployData calldata data) internal returns (address) {
        address admin = data.admin;
        if (admin == address(0)) {
            admin = _msgSender();
        }
        address assetHub = IAssetHubFactory(_implData.assetHubFactory).createUUPSUpgradeable('');
        address collectNFT;
        if (data.collectNft) {
            collectNFT = IModuleFactory(_implData.collectNFTFactory).createUUPSUpgradeable(
                assetHub,
                ''
            );
        }

        AssetHubInfo memory info = AssetHubInfo({
            assetHub: assetHub,
            feeCollectModule: _deployFeeCollectModule(assetHub),
            nftGatedModule: _deployNftAssetGatedModule(assetHub),
            assetCreateModule: data.assetCreateModule,
            collectNFT: collectNFT
        });
        _assetHubs[assetHub] = info;
        _namedHubs[data.name] = assetHub;

        IAssetHub(assetHub).initialize(
            data.name,
            data.name,
            admin,
            collectNFT,
            data.assetCreateModule,
            info.feeCollectModule
        );

        emit AssetHubDeployed(
            admin,
            data.name,
            info.assetHub,
            info.feeCollectModule,
            info.nftGatedModule,
            info.assetCreateModule
        );
        return info.assetHub;
    }

    function _deployFeeCollectModule(address hub) internal returns (address) {
        return IModuleFactory(_implData.feeCollectModuleFactory).createUUPSUpgradeable(hub, '');
    }

    function _deployNftAssetGatedModule(address hub) internal returns (address) {
        return IModuleFactory(_implData.nftGatedModuleFactory).createUUPSUpgradeable(hub, '');
    }
}
