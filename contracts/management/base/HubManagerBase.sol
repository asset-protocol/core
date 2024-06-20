// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MultipleBeacon} from '../../upgradeability/MultipleBeacon.sol';
import {MultipleBeaconProxy} from '../../upgradeability/MultipleBeaconProxy.sol';
import {StorageSlots, LiteHubStorage} from './StorageSlots.sol';
import {HubCreateData, IAssetHubManagerEvents, AssetHubInfo} from '../../interfaces/IAssetHubManager.sol';
import {IAssetHub} from '../../interfaces/IAssetHub.sol';

struct MangerInitData {
    address assetHubImpl;
    address tokenCreateModule;
    address collectNFT;
    address feeCollectModule;
    address tokenCollectModule;
    address nftGatedModule;
}

contract HubManagerBase is MultipleBeacon, IAssetHubManagerEvents {
    error NoAssetHubImplementation();
    event ModulesInitialized(MangerInitData modules);

    struct HubModulesStorage {
        address tokenCreateModule;
        address collectNFT;
        address feeCollectModule;
        address tokenCollectModule;
        address nftGatedModule;
    }

    // keccak256(abi.encode(uint256(keccak256('litehubmanager.storage.modules')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ModuleStorageLocation =
        0x766d2447ffa670bd44ca6bd3f205f098585331965b3439f5d4d562261485c100;

    function getModulesStorage() internal pure returns (HubModulesStorage storage $) {
        assembly {
            $.slot := ModuleStorageLocation
        }
    }

    function __LiteHubManagerBase_init(MangerInitData calldata data) internal {
        if (data.assetHubImpl != address(0)) {
            _upgradeTo(StorageSlots.IMPL_ASSETHUB, data.assetHubImpl);
        }

        HubModulesStorage storage $ = getModulesStorage();
        $.tokenCreateModule = data.tokenCreateModule;
        $.collectNFT = data.collectNFT;
        $.feeCollectModule = data.feeCollectModule;
        $.nftGatedModule = data.nftGatedModule;
        $.tokenCollectModule = data.tokenCollectModule;
        emit ModulesInitialized(data);
    }

    function assetHubImpl() public view returns (address) {
        return implementation(StorageSlots.IMPL_ASSETHUB);
    }

    function assetHubInfo(address hub) external view returns (AssetHubInfo memory) {
        return StorageSlots.getLiteHub(hub);
    }

    function hubDefaultModules() external view returns (HubModulesStorage memory) {
        HubModulesStorage storage $ = getModulesStorage();
        return
            HubModulesStorage({
                tokenCreateModule: $.tokenCreateModule,
                collectNFT: $.collectNFT,
                feeCollectModule: $.feeCollectModule,
                tokenCollectModule: $.tokenCollectModule,
                nftGatedModule: $.nftGatedModule
            });
    }

    function assetHubInfoByName(string calldata name) external view returns (AssetHubInfo memory) {
        return StorageSlots.getLiteHubByName(name);
    }

    function hasNamedHub(string calldata name) external view returns (bool) {
        return StorageSlots.hasNamedHub(name);
    }

    function _isHub(address hub) internal view returns (bool) {
        return StorageSlots.hasHub(hub);
    }

    function _createHub(HubCreateData calldata data) internal virtual returns (address) {
        if (assetHubImpl() == address(0)) {
            revert NoAssetHubImplementation();
        }
        address hub = _createProxy(StorageSlots.IMPL_ASSETHUB);
        HubModulesStorage storage $ = getModulesStorage();
        address[] memory collectModules = new address[](2);
        collectModules[0] = $.feeCollectModule;
        collectModules[1] = $.tokenCollectModule;
        address admin = data.admin;
        if (data.admin == address(0)) {
            admin = msg.sender;
        }
        IAssetHub(hub).initialize(
            data.name,
            address(this),
            admin,
            $.collectNFT,
            data.createModule,
            collectModules,
            data.contractURI
        );
        AssetHubInfo memory info = AssetHubInfo({
            createModule: data.createModule,
            feeCollectModule: $.feeCollectModule,
            tokenCollectModule: $.tokenCollectModule,
            nftGatedModule: $.nftGatedModule,
            contractURI: data.contractURI
        });
        StorageSlots.createHub(data.name, hub, admin, info);
        emit AssetHubDeployed(admin, data.name, hub, info);
        return hub;
    }

    function _createProxy(uint index) internal returns (address) {
        MultipleBeaconProxy proxy = new MultipleBeaconProxy(address(this), index);
        return address(proxy);
    }
}
