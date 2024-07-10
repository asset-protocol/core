// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Proxy} from '@openzeppelin/contracts/proxy/Proxy.sol';
import {IMultipleBeacon} from '../interfaces/IMultipleBeacon.sol';

contract MultipleBeaconProxy is Proxy {
    address private immutable _beacon;
    uint private _implIndex;

    constructor(address beacon, uint implIndex) {
        _beacon = beacon;
        _implIndex = implIndex;
    }

    function _implementation() internal view virtual override returns (address) {
        return IMultipleBeacon(_getBeacon()).implementation(_implIndex);
    }

    /**
     * @dev Returns the beacon.
     */
    function _getBeacon() internal view virtual returns (address) {
        return _beacon;
    }
}
