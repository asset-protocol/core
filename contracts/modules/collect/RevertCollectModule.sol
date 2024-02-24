// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICollectModule} from '../../interfaces/ICollectModule.sol';

contract RevertCollectModule is ICollectModule {
    function processCollect(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes memory) {
        revert('RevertCollectModule');
    }

    function initialModule(
        address,
        uint256,
        bytes calldata
    ) external override returns (bytes memory) {}
}
