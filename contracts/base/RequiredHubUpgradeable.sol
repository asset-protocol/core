// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Errors} from '../libs/Errors.sol';
import {Initializable} from '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import {ContextUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol';

abstract contract RequiredHubUpgradeable is Initializable, ContextUpgradeable {
    address public HUB;

    modifier onlyHub() {
        if (msg.sender != HUB) {
            revert Errors.NotHub();
        }
        _;
    }

    function __RequiredHub_init(address hub) internal {
        HUB = hub;
    }
}
