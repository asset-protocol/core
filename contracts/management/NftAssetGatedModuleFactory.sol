// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IModuleFactory} from './IFactory.sol';
import {UpgradeableProxy} from '../upgradeability/UpgradeableProxy.sol';
import {NftAssetGatedModule} from '../modules/asset/NftAssetGatedModule.sol';

contract NftAssetGatedModuleFactory is IModuleFactory {
    function createUUPSUpgradeable(
        address hub,
        bytes calldata initData
    ) external override returns (address) {
        UpgradeableProxy proxy = new UpgradeableProxy(_createImpl(hub, initData), '');
        NftAssetGatedModule(address(proxy)).initialize(hub);
        return address(proxy);
    }

    function create(address hub, bytes calldata initData) external override returns (address) {
        return _createImpl(hub, initData);
    }

    function _createImpl(address, bytes calldata) internal returns (address) {
        NftAssetGatedModule impl = new NftAssetGatedModule();
        return address(impl);
    }
}
