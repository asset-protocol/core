// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1967Proxy} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';
import {IAssetHubFactory, IUUPSUpgradeable} from './IFactory.sol';
import {AssetHub} from '../AssetHub.sol';

contract AssetHubFactory is IAssetHubFactory {
    function createUUPSUpgradeable(bytes calldata initData) external returns (address) {
        address assetHubImpl = _createImpl(initData);
        ERC1967Proxy proxy = new ERC1967Proxy(assetHubImpl, '');
        return address(proxy);
    }

    function create(bytes calldata initData) public returns (address) {
        return _createImpl(initData);
    }

    function _createImpl(bytes calldata) internal returns (address) {
        AssetHub assetHubImpl = new AssetHub();
        return address(assetHubImpl);
    }
}
