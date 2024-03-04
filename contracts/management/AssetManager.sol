// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {UUPSUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import {WhitelistBase} from '../base/WhitlistBase.sol';
import {IModuleFactory, IAssetHubFactory} from './IFactory.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {CollectNFT} from '../core/CollectNFT.sol';

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

contract AssetHubManager is OwnableUpgradeable, UUPSUpgradeable, WhitelistBase {
    mapping(address => AssetHubInfo) private _assetHubs;
    mapping(string => address) _namedHubs;
    AssetHubImplData internal _implData;

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

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _deployHub(AssetHubDeployData calldata data) internal returns (address) {
        address admin = data.admin;
        if (admin == address(0)) {
            admin = _msgSender();
        }
        address assetHub = IAssetHubFactory(_implData.assetHubFactory).create('');
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
        return IModuleFactory(_implData.feeCollectModuleFactory).create(hub, abi.encode(admin));
    }

    function _deployNftAssetGatedModule(address hub, address admin) internal returns (address) {
        return IModuleFactory(_implData.nftGatedModuleFactory).create(hub, abi.encode(admin));
    }

    function _deployAssetCreateModule(address hub, address admin) internal returns (address) {
        return IModuleFactory(_implData.feeCreateAssetModuleFactory).create(hub, abi.encode(admin));
    }
}
