// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

abstract contract UpgradeableBase is UUPSUpgradeable {
    function version() external virtual returns (string memory);
}
