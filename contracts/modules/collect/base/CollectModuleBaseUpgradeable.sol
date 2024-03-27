// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICollectModule} from '../../../interfaces/ICollectModule.sol';
import {RequiredHubUpgradeable} from '../../../base/RequiredHubUpgradeable.sol';
import {ERC165Upgradeable} from '@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol';

abstract contract CollectModuleBaseUpgradeable is
    ICollectModule,
    RequiredHubUpgradeable,
    ERC165Upgradeable
{
    function __CollectModuleBaseUpgradeable_init(address hub) internal onlyInitializing {
        __ERC165_init();
        __RequiredHub_init(hub);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(ICollectModule).interfaceId || super.supportsInterface(interfaceId);
    }
}
