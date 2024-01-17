// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {TransparentUpgradeableProxy} from '@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol';

contract UpgradeableProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address _admin,
        bytes memory _data
    ) payable TransparentUpgradeableProxy(_logic, _admin, _data) {}
}
