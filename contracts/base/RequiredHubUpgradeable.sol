// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Errors} from '../libs/Errors.sol';
import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import {ContextUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';

abstract contract RequiredHubUpgradeable is Initializable, ContextUpgradeable {
    address public HUB;

    error NotHubOwner();

    function __RequiredHub_init(address hub) internal {
        HUB = hub;
    }

    modifier onlyHub() {
        if (msg.sender != HUB) {
            revert Errors.NotHub();
        }
        _;
    }

    modifier onlyHubOwner() {
        _checkHubOwner(msg.sender);
        _;
    }

    function _checkHubOwner(address account) internal view {
        if (HUB == account) {
            return;
        }
        if (IAssetHub(HUB).hubOwner() != account) {
            revert NotHubOwner();
        }
    }

    function _checkAssetOwner(uint256 assetId, address account) internal view {
        if (IAssetHub(HUB).assetPublisher(assetId) != account) {
            revert NotHubOwner();
        }
    }
}
