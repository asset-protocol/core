// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MultipleBeacon} from '../../upgradeability/MultipleBeacon.sol';
import {MultipleBeaconProxy} from '../../upgradeability/MultipleBeaconProxy.sol';
import {StorageSlots, LiteHubStorage, LiteHubInfo} from './StorageSlots.sol';
import {HubCreateData} from '../../interfaces/IAssetHubManager.sol';
import {IAssetHub} from '../../interfaces/IAssetHub.sol';

struct MangerInitData {
    address assetHubImpl;
    address tokenCreateModule;
    address collectNFT;
    address feeCollectModule;
    address tokenCollectModule;
    address nftGatedModule;
}

contract LiteHubManagerBase is MultipleBeacon {
    error NoAssetHubImplementation();

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

    event AssetHubDeployed(address indexed admin, string name, address assetHub, LiteHubInfo data);

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
    }

    function assetHubImpl() public view returns (address) {
        return implementation(StorageSlots.IMPL_ASSETHUB);
    }

    function assetHubInfo(address hub) external view returns (LiteHubInfo memory) {
        return StorageSlots.getLiteHub(hub);
    }

    function assetHubInfoByName(string calldata name) external view returns (LiteHubInfo memory) {
        return StorageSlots.getLiteHubByName(name);
    }

    function _createHub(HubCreateData calldata data) internal virtual returns (address) {
        if (assetHubImpl() == address(0)) {
            revert NoAssetHubImplementation();
        }
        address hub = _createProxy(StorageSlots.IMPL_ASSETHUB);

        HubModulesStorage storage $ = getModulesStorage();
        LiteHubInfo memory info;
        info.createModule = data.createModule;
        info.feeCollectModule = $.feeCollectModule;
        info.tokenCollectModule = $.tokenCollectModule;
        info.nftGatedModule = $.nftGatedModule;
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
            info.createModule,
            collectModules
        );
        StorageSlots.createHub(data.name, hub, admin, info);
        emit AssetHubDeployed(admin, data.name, hub, info);
        return hub;
    }

    function _createProxy(uint index) internal returns (address) {
        MultipleBeaconProxy proxy = new MultipleBeaconProxy(address(this), index);
        return address(proxy);
    }
}
