// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IModuleFactory} from './IFactory.sol';
import {CollectNFT} from '../CollectNFT.sol';

contract CollectNFTFactory is IModuleFactory {
    function create(address hub, bytes calldata) public override returns (address) {
        return address(new CollectNFT(hub));
    }

    function createUUPSUpgradeable(
        address hub,
        bytes calldata initData
    ) external override returns (address) {
        return create(hub, initData);
    }
}
