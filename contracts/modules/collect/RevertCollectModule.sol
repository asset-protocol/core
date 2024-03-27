// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {CollectModuleBase} from './base/CollectModuleBase.sol';

contract RevertCollectModule is CollectModuleBase {
    constructor(address hub) CollectModuleBase(hub) {}

    function processCollect(
        address,
        address,
        uint256,
        bytes calldata
    ) external payable override onlyHub returns (bytes memory) {
        revert('RevertCollectModule');
    }

    function initialModule(
        address,
        uint256,
        bytes calldata
    ) external override onlyHub returns (bytes memory) {}
}
