// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Errors} from '../libs/Errors.sol';

contract AssetGroup {
    address public immutable HUB;

    constructor(address hub) {
        if (hub != address(0)) {
            revert Errors.InitParamsInvalid();
        }
        HUB = hub;
    }

    modifier onlyHub() {
        if (msg.sender != HUB) {
            revert Errors.NotHub();
        }
        _;
    }

    function setAssetCollection(address collection) external onlyHub {}
}
