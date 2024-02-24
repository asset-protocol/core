// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Errors} from '../libs/Errors.sol';

abstract contract RequiredHub {
    address public immutable HUB;

    modifier onlyHub() {
        if (msg.sender != HUB) {
            revert Errors.NotHub();
        }
        _;
    }

    constructor(address hub) {
        HUB = hub;
    }
}
