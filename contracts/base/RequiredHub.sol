// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Errors} from '../libs/Errors.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';

abstract contract RequiredHub {
    address public immutable HUB;

    error NotHubOwner();

    constructor(address hub) {
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

    modifier onlyAssetOwner(uint256 assetId) {
        _checkAssetOwner(assetId, msg.sender);
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
