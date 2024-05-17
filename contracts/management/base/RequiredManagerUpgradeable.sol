// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import {ContextUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol';
import {IAssetHub} from '../../interfaces/IAssetHub.sol';
import {IAssetHubManager} from '../../interfaces/IAssetHubManager.sol';
import {IOwnable} from '../../interfaces/IOwnable.sol';
import {StorageSlots} from './StorageSlots.sol';
import 'hardhat/console.sol';

abstract contract RequiredManagerUpgradeable is Initializable, ContextUpgradeable {
    error NotManager();
    error NotHub();
    error NotHubOwner();

    function __RequiredManager_init(address manager_) internal onlyInitializing {
        require(manager_ != address(0), 'Manager address cannot be zero');
        StorageSlots.setManager(manager_);
    }

    modifier onlyManager() {
        if (msg.sender != StorageSlots.getManager()) {
            revert NotManager();
        }
        _;
    }

    modifier onlyHub() {
        _checkHub(_msgSender());
        _;
    }

    function manager() external view returns (address) {
        return StorageSlots.getManager();
    }

    function _checkHub(address hub) internal view {
        bool isHub = IAssetHubManager(StorageSlots.getManager()).isHub(hub);
        if (!isHub) {
            revert NotHub();
        }
    }

    function _checkHubOwner(address hub, address account) internal view {
        if (hub == account) {
            return;
        }
        if (IAssetHub(hub).hubOwner() != account) {
            revert NotHubOwner();
        }
    }

    function _checkAssetOwner(address hub, uint256 assetId, address account) internal view {
        _checkHub(hub);
        if (IAssetHub(hub).assetPublisher(assetId) != account) {
            revert NotHubOwner();
        }
    }

    function _globalModule() internal view returns (address) {
        return IAssetHubManager(StorageSlots.getManager()).globalModule();
    }

    function _managerOwner() internal view returns (address) {
        return IOwnable(StorageSlots.getManager()).owner();
    }
}
