// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IFactory} from '../interfaces/IFactory.sol';
import {ERC1967Proxy} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';
import {FeeCreateAssetModule} from '../modules/asset/FeeCreateAssetModule.sol';

contract FeeCreateAssetModuleFactory is IFactory {
    function create(bytes calldata /* initdata */) external returns (address) {
        FeeCreateAssetModule impl = new FeeCreateAssetModule();
        return address(impl);
    }
}
