// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';
import {WhitelistBase} from '../base/WhitlistBase.sol';
import {IModuleFactory, IAssetHubFactory} from './IFactory.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {CollectNFT} from '../CollectNFT.sol';

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
}

struct AssetHubImplData {
    address assetHubFactory;
    address feeCollectModuleFactory;
    address nftGatedModuleFactory;
    address feeCreateAssetModuleFactory;
}

struct AssetHubImplInitData {
    address assetHubFactory;
    address feeCollectModuleFactory;
    address nftGatedModuleFactory;
    address feeCreateAssetModuleFactory;
}

contract AssetHubManager is OwnableUpgradeable, UpgradeableBase, WhitelistBase {
    string private VERSION = '1.0.0';

    AssetHubImplData internal _implData;
    mapping(string => address) private _namedHubs;
    mapping(address => AssetHubInfo) private _assetHubs;

    event AssetHubDeployed(
        address indexed admin,
        address assetHub,
        address feeCollectModule,
        address nftGatedModule,
        address feeAssetCreateModule
    );

    error NameHubExisted();
    error AssetHubNotExisted();

    function initialize(AssetHubImplInitData calldata data) external initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __AssetHubFactory_init(data);
        _setWhitelist(_msgSender(), true);
    }

    function __AssetHubFactory_init(AssetHubImplInitData calldata data) internal onlyInitializing {
        _implData.assetHubFactory = data.assetHubFactory;
        _implData.feeCollectModuleFactory = data.feeCollectModuleFactory;
        _implData.nftGatedModuleFactory = data.nftGatedModuleFactory;
        _implData.feeCreateAssetModuleFactory = data.feeCreateAssetModuleFactory;
    }

    function version() external virtual override returns (string memory) {
        return VERSION;
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

    function exitsName(string calldata name) public view returns (bool) {
        return _namedHubs[name] != address(0);
    }

    function deploy(AssetHubDeployData calldata data) external returns (address) {
        _checkWhitelisted(_msgSender());
        if (_implData.assetHubFactory == address(0)) {
            revert('AssetHubFactory: not initialized');
        }
        if (exitsName(data.name)) {
            revert NameHubExisted();
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

    function createFeeAssetCreateModuleImpl(
        address hub,
        bytes calldata initData
    ) external returns (address) {
        _checkWhitelisted(_msgSender());
        return IModuleFactory(_implData.feeCreateAssetModuleFactory).create(hub, initData);
    }

    function factories() external view returns (AssetHubImplData memory) {
        return _implData;
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
            collectNFT = address(new CollectNFT(assetHub));
        }
        IAssetHub(assetHub).initialize(data.name, data.name, admin, collectNFT, address(0));

        AssetHubInfo memory info = AssetHubInfo({
            assetHub: assetHub,
            feeCollectModule: _deployFeeCollectModule(address(assetHub), admin),
            nftGatedModule: _deployNftAssetGatedModule(address(assetHub), admin),
            assetCreateModule: _deployAssetCreateModule(address(assetHub), admin),
            collectNFT: collectNFT
        });
        _assetHubs[address(assetHub)] = info;
        emit AssetHubDeployed(
            admin,
            info.assetHub,
            info.feeCollectModule,
            info.nftGatedModule,
            info.assetCreateModule
        );
        return info.assetHub;
    }

    function _deployFeeCollectModule(address hub, address admin) internal returns (address) {
        return
            IModuleFactory(_implData.feeCollectModuleFactory).createUUPSUpgradeable(
                hub,
                abi.encode(admin)
            );
    }

    function _deployNftAssetGatedModule(address hub, address admin) internal returns (address) {
        return
            IModuleFactory(_implData.nftGatedModuleFactory).createUUPSUpgradeable(
                hub,
                abi.encode(admin)
            );
    }

    function _deployAssetCreateModule(address hub, address admin) internal returns (address) {
        return IModuleFactory(_implData.feeCreateAssetModuleFactory).create(hub, abi.encode(admin));
    }
}
