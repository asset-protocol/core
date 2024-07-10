// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICreateAssetModule} from '../../interfaces/ICreateAssetModule.sol';
import {UpgradeableBase} from '../../upgradeability/UpgradeableBase.sol';
import {RequiredHubUpgradeable} from '../../base/RequiredHubUpgradeable.sol';

contract NftAssetCreateModule is ICreateAssetModule, UpgradeableBase, RequiredHubUpgradeable {
    function initialize(address hub) external initializer {
        __UUPSUpgradeable_init();
        __RequiredHub_init(hub);
    }

    function processCreate(
        address /*publisher*/,
        uint256 /*assetId*/,
        bytes calldata /* data*/
    ) external pure override returns (bytes memory) {
        return bytes('');
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyHubOwner {}
}
