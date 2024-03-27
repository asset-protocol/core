// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICollectModule} from '../../../interfaces/ICollectModule.sol';
import {RequiredHub} from '../../../base/RequiredHub.sol';
import {ERC165} from '@openzeppelin/contracts/utils/introspection/ERC165.sol';

abstract contract CollectModuleBase is ICollectModule, RequiredHub, ERC165 {
    constructor(address hub) RequiredHub(hub) {}

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(ICollectModule).interfaceId || super.supportsInterface(interfaceId);
    }
}
