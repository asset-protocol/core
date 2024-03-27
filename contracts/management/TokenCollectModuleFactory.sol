// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IModuleFactory} from './IFactory.sol';
import {UpgradeableProxy} from '../upgradeability/UpgradeableProxy.sol';
import {TokenCollectModule} from '../modules/collect/TokenCollectModule.sol';

contract TokenCollectModuleFactory is IModuleFactory {
    function createUUPSUpgradeable(
        address hub,
        bytes calldata initData
    ) external override returns (address) {
        UpgradeableProxy proxy = new UpgradeableProxy(_createImpl(initData), new bytes(0));
        TokenCollectModule(address(proxy)).initialize(hub);
        return address(proxy);
    }

    function create(address, bytes calldata initData) external override returns (address) {
        return _createImpl(initData);
    }

    function _createImpl(bytes calldata) internal returns (address) {
        TokenCollectModule impl = new TokenCollectModule();
        return address(impl);
    }
}
