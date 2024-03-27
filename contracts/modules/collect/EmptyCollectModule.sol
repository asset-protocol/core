// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CollectModuleBase} from './base/CollectModuleBase.sol';

contract EmptyCollectModule is CollectModuleBase {
    constructor(address hub) CollectModuleBase(hub) {}

    function processCollect(
        address,
        address,
        uint256,
        bytes calldata
    ) external payable override returns (bytes memory) {
        return '';
    }

    function initialModule(
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes memory) {
        return '';
    }
}
