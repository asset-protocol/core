// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BeaconProxy} from '@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol';
import {Proxy} from '@openzeppelin/contracts/proxy/Proxy.sol';

contract BeaconProxyBase is BeaconProxy {
    constructor(address beacon, bytes memory data) payable BeaconProxy(beacon, data) {}
}
