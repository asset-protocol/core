// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import {ContextUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol';
import {IAssetHub} from '../../interfaces/IAssetHub.sol';
import {IAssetHubManager} from '../../interfaces/IAssetHubManager.sol';
import {StorageSlots} from './StorageSlots.sol';
import 'hardhat/console.sol';

abstract contract RequiredManagerUpgradeable is Initializable, ContextUpgradeable {
    error NotManager();
    error NotHub();
    error NotHubOwner();

    function __RequiredManager_init(address manager) internal onlyInitializing {
        StorageSlots.setManager(manager);
    }

    modifier onlyManager() {
        if (msg.sender != StorageSlots.getManager()) {
            revert NotManager();
        }
        _;
    }

    modifier onlyHub() {
        _checkHub();
        _;
    }

    function _checkHub() internal view {
        bool isHub = IAssetHubManager(StorageSlots.getManager()).isHub(_msgSender());
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
        if (IAssetHub(hub).assetPublisher(assetId) != account) {
            revert NotHubOwner();
        }
    }
}
