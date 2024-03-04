// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IModuleFactory} from './IFactory.sol';
import {ERC1967Proxy} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';
import {FeeCollectModule} from '../modules/collect/FeeCollectModule.sol';

contract FeeCollectModuleFactory is IModuleFactory {
    function create(address hub, bytes calldata) external override returns (address) {
        FeeCollectModule impl = new FeeCollectModule();
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), '');
        FeeCollectModule(address(proxy)).initialize(hub);
        return address(proxy);
    }
}
