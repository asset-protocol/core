// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IAssetHubFactory} from './IFactory.sol';
import {TokenGlobalModule, TokenFeeConfig} from '../modules/global/TokenGlobalModule.sol';
import {UpgradeableProxy} from '../upgradeability/UpgradeableProxy.sol';

contract TokenGlobalModuleFactory is IAssetHubFactory {
    function create(bytes calldata initData) external override returns (address) {
        return _createImpl(initData);
    }

    function createUUPSUpgradeable(bytes calldata initData) external override returns (address) {
        UpgradeableProxy proxy = new UpgradeableProxy(_createImpl(initData), new bytes(0));
        TokenFeeConfig memory config;
        TokenGlobalModule(address(proxy)).initialize(msg.sender, address(0), config);
        return address(proxy);
    }

    function _createImpl(bytes calldata) internal returns (address) {
        TokenGlobalModule impl = new TokenGlobalModule();
        return address(impl);
    }
}
