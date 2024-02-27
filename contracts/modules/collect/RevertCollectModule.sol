// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICollectModule} from '../../interfaces/ICollectModule.sol';
import {RequiredHub} from '../../base/RequiredHub.sol';

contract RevertCollectModule is RequiredHub, ICollectModule {
    constructor(address hub) RequiredHub(hub) {}

    function processCollect(
        address,
        address,
        uint256,
        bytes calldata
    ) external view override onlyHub returns (bytes memory) {
        revert('RevertCollectModule');
    }

    function initialModule(
        address,
        uint256,
        bytes calldata
    ) external override onlyHub returns (bytes memory) {}
}
