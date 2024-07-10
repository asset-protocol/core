// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICollectModule} from './ICollectModule.sol';

interface ITokenCollectModule is ICollectModule {
    function initialize(address hub, address admin) external;
}
