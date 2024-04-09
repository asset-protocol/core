// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IModuleFactory} from './IFactory.sol';
import {TokenAssetCreateModule} from '../modules/asset/TokenAssetCreateModule.sol';

contract TokenAssetCreateModuleFactory is IModuleFactory {
    function createUUPSUpgradeable(
        address,
        bytes calldata
    ) external pure override returns (address) {
        revert NotImplemented();
    }

    function create(address hub, bytes calldata) external override returns (address) {
        TokenAssetCreateModule impl = new TokenAssetCreateModule(hub);
        return address(impl);
    }
}
