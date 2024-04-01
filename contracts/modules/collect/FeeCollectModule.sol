// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CollectModuleBaseUpgradeable} from './base/CollectModuleBaseUpgradeable.sol';
import {UpgradeableBase} from '../../upgradeability/UpgradeableBase.sol';
import {IAssetHub} from '../../interfaces/IAssetHub.sol';

struct FeeCollectConfig {
    address payable recipient;
    uint256 amount;
}

contract FeeCollectModule is UpgradeableBase, CollectModuleBaseUpgradeable {
    mapping(uint256 => FeeCollectConfig) internal _configs;

    function initialize(address hub) external initializer {
        __CollectModuleBaseUpgradeable_init(hub);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyHubOwner {}

    function initialModule(
        address /*publisher*/,
        uint256 assetId,
        bytes calldata data
    ) external virtual override onlyHub returns (bytes memory) {
        FeeCollectConfig memory config = abi.decode(data, (FeeCollectConfig));
        _configs[assetId] = config;
        return '';
    }

    function processCollect(
        address /*collector */,
        address /*publisher*/,
        uint256 assetId,
        bytes calldata
    ) external payable virtual override onlyHub returns (bytes memory) {
        FeeCollectConfig memory config = _configs[assetId];
        if (config.amount == 0) return '';
        address payable recipient = config.recipient;
        if (recipient == address(0)) {
            recipient = payable(IAssetHub(HUB).assetPublisher(assetId));
        }
        require(recipient != address(0),"recipient should not be zero");
        recipient.transfer(config.amount);
        return '';
    }
}
