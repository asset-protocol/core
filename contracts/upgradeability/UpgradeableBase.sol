// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

abstract contract Version {
    function version() external view virtual returns (string memory);
}

abstract contract UpgradeableBase is UUPSUpgradeable, Version {}
