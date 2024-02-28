// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {UUPSUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import {ERC1967Proxy} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';
import {Clones} from '@openzeppelin/contracts/proxy/Clones.sol';
import {WhitelistBase} from '../base/WhitlistBase.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {IFeeCollectModule} from '../interfaces/IFeeCollectModule.sol';
import {INftAssetGatedModule} from '../interfaces/INftAssetGatedModule.sol';
import {CollectNFT} from './CollectNFT.sol';

struct AssetHubInfo {
    address assetHub;
    address feeCollectModule;
    address nftGatedModule;
}

struct AssetHubDeployData {
    address admin;
    string name;
    bool collectNft;
}

struct AssetHubImplData {
    address assetHubImpl;
    address feeCollectModuleImpl;
    address nftGatedModuleImpl;
    address feeCreateAssetModuleImpl;
    address etraImpl1;
    address etraImpl2;
    address etraImpl3;
}

struct AssetHubImplInitData {
    address assetHubImpl;
    address feeCollectModuleImpl;
    address nftGatedModuleImpl;
    // address feeCreateAssetModuleImpl;
}

contract AssetHubFactory is OwnableUpgradeable, UUPSUpgradeable, WhitelistBase {
    mapping(address => AssetHubInfo) private _assetHubs;
    AssetHubImplData internal _implData;

    event AssetHubDeployed(address indexed admin, AssetHubInfo info);

    function initialize(AssetHubImplInitData calldata data) external initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __AssetHubFactory_init(data);
        _setWhitelist(_msgSender(), true);
    }

    function __AssetHubFactory_init(AssetHubImplInitData calldata data) internal onlyInitializing {
        _implData.assetHubImpl = data.assetHubImpl;
        _implData.feeCollectModuleImpl = data.feeCollectModuleImpl;
        _implData.nftGatedModuleImpl = data.nftGatedModuleImpl;
        // _implData.feeCreateAssetModuleImpl = data.feeCreateAssetModuleImpl;
    }

    function setWhitelist(address account, bool whitelist) external onlyOwner {
        _setWhitelist(account, whitelist);
    }

    // function assetHubInfo(address hub) external view returns (AssetHubInfo memory) {
    //     return _assetHubs[hub];
    // }

    function deploy(AssetHubDeployData calldata data) external {
        _checkWhitelisted(_msgSender());
        if (_implData.assetHubImpl == address(0)) {
            revert('AssetHubFactory: not initialized');
        }
        _deployHub(data);
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _deployHub(AssetHubDeployData calldata data) internal {
        address admin = data.admin;
        if (admin == address(0)) {
            admin = _msgSender();
        }

        address assetHub = Clones.clone(_implData.assetHubImpl);
        AssetHubInfo memory info = AssetHubInfo({
            assetHub: assetHub,
            feeCollectModule: _deployFeeCollectModule(address(assetHub), admin),
            nftGatedModule: _deployNftAssetGatedModule(address(assetHub), admin)
        });

        address collectNFT;
        if (data.collectNft) {
            collectNFT = address(new CollectNFT(address(assetHub)));
        }
        IAssetHub(assetHub).initialize(data.name, data.name, admin, collectNFT, address(0));
        _assetHubs[address(assetHub)] = info;
        emit AssetHubDeployed(admin, info);
    }

    function _deployFeeCollectModule(address hub, address admin) internal returns (address) {
        address feeCollectImpl = Clones.clone(_implData.feeCollectModuleImpl);
        ERC1967Proxy feeCollectProxy = new ERC1967Proxy(address(feeCollectImpl), '');
        IFeeCollectModule(address(feeCollectProxy)).initialize(hub, admin);
        return address(feeCollectProxy);
    }

    function _deployNftAssetGatedModule(address hub, address admin) internal returns (address) {
        address nftGatedImpl = Clones.clone(_implData.nftGatedModuleImpl);
        ERC1967Proxy nftGatedProxy = new ERC1967Proxy(address(nftGatedImpl), '');
        INftAssetGatedModule(address(nftGatedProxy)).initialize(hub, admin);
        return address(nftGatedProxy);
    }
}
