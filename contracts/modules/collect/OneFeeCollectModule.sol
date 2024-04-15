// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OneCollectModuleBaseUpgradeable} from './base/OneCollectModuleBaseUpgradeable.sol';
import {Version} from '../../upgradeability/UpgradeableBase.sol';
import {IAssetHub} from '../../interfaces/IAssetHub.sol';

struct FeeCollectConfig {
    address payable recipient;
    uint256 amount;
}

contract OneFeeCollectModule is Version, OneCollectModuleBaseUpgradeable {
    mapping(address => mapping(uint256 => FeeCollectConfig)) internal _configs;

    function initialize(address manager) external initializer {
        __OneCollectModuleBaseUpgradeable_init(manager);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function initialModule(
        address /*publisher*/,
        uint256 assetId,
        bytes calldata data
    ) external virtual override onlyHub returns (bytes memory) {
        address hub = _msgSender();
        FeeCollectConfig memory config = abi.decode(data, (FeeCollectConfig));
        _configs[hub][assetId] = config;
        return '';
    }

    function processCollect(
        address /*collector */,
        address /*publisher*/,
        uint256 assetId,
        bytes calldata
    ) external payable virtual override onlyHub returns (bytes memory) {
        address hub = _msgSender();
        FeeCollectConfig memory config = _configs[hub][assetId];
        if (config.amount == 0) return '';
        address payable recipient = config.recipient;
        if (recipient == address(0)) {
            recipient = payable(IAssetHub(hub).assetPublisher(assetId));
        }
        require(recipient != address(0), 'recipient should not be zero');
        recipient.transfer(config.amount);
        return '';
    }
}
