// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UpgradeableProxy} from '../upgradeability/UpgradeableProxy.sol';
import {IAssetHubFactory} from './IFactory.sol';
import {AssetHub} from '../AssetHub.sol';

contract AssetHubFactory is IAssetHubFactory {
    function createUUPSUpgradeable(bytes calldata initData) external returns (address) {
        address assetHubImpl = _createImpl(initData);
        UpgradeableProxy proxy = new UpgradeableProxy(assetHubImpl, new bytes(0));
        return address(proxy);
    }

    function create(bytes calldata initData) public returns (address) {
        return _createImpl(initData);
    }

    function _createImpl(bytes calldata) internal returns (address) {
        AssetHub assetHubImpl = new AssetHub();
        return address(assetHubImpl);
    }
}
