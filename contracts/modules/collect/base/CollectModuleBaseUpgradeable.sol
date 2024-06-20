// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICollectModule} from '../../../interfaces/ICollectModule.sol';
import {RequiredManagerUpgradeable} from '../../../management/base/RequiredManagerUpgradeable.sol';
import {ERC165Upgradeable} from '@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol';

abstract contract CollectModuleBaseUpgradeable is
    ICollectModule,
    RequiredManagerUpgradeable,
    ERC165Upgradeable
{
    function __CollectModuleBaseUpgradeable_init(address manager) internal onlyInitializing {
        __ERC165_init();
        __RequiredManager_init(manager);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(ICollectModule).interfaceId || super.supportsInterface(interfaceId);
    }
}
