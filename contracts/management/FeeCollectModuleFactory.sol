// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IModuleFactory} from './IFactory.sol';
import {UpgradeableProxy} from '../upgradeability/UpgradeableProxy.sol';
import {FeeCollectModule} from '../modules/collect/FeeCollectModule.sol';

contract FeeCollectModuleFactory is IModuleFactory {
    function createUUPSUpgradeable(
        address hub,
        bytes calldata initData
    ) external override returns (address) {
        UpgradeableProxy proxy = new UpgradeableProxy(_createImpl(initData), '');
        FeeCollectModule(address(proxy)).initialize(hub);
        return address(proxy);
    }

    function create(address, bytes calldata initData) external override returns (address) {
        return _createImpl(initData);
    }

    function _createImpl(bytes calldata) internal returns (address) {
        FeeCollectModule impl = new FeeCollectModule();
        return address(impl);
    }
}
