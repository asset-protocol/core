// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IFactory} from '../interfaces/IFactory.sol';
import {ERC1967Proxy} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';
import {NftAssetGatedModule} from '../modules/asset/NftAssetGatedModule.sol';

contract NftAssetGatedModuleFactory is IFactory {
    function create(bytes calldata initData) external returns (address) {
        NftAssetGatedModule impl = new NftAssetGatedModule();
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), '');
        (address hub, address admin) = abi.decode(initData, (address, address));
        NftAssetGatedModule(address(proxy)).initialize(hub, admin);
        return address(proxy);
    }
}
