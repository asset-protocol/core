// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UUPSUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';

abstract contract UpgradeableBase is UUPSUpgradeable {
    uint8 private _version;

    function version() external view virtual returns (uint8) {
        return _version;
    }

    function upgradeToAndCall(
        address newImplementation,
        bytes memory data
    ) public payable virtual override onlyProxy {
        super.upgradeToAndCall(newImplementation, data);
        _version = _version + 1;
    }
}
