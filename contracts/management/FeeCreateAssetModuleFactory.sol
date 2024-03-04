// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IModuleFactory} from './IFactory.sol';
import {FeeCreateAssetModule} from '../modules/asset/FeeCreateAssetModule.sol';

contract FeeCreateAssetModuleFactory is IModuleFactory {
    function create(address hub, bytes calldata) external override returns (address) {
        FeeCreateAssetModule impl = new FeeCreateAssetModule(hub);
        return address(impl);
    }
}
