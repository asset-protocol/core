// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICollectModule} from '../../interfaces/ICollectModule.sol';

contract EmptyCollectModule is ICollectModule {
    function processCollect(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes memory) {
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
