// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC165Upgradeable} from '@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol';
import {UpgradeableBase} from '../../upgradeability/UpgradeableBase.sol';
import {RequiredManagerUpgradeable} from '../../management/base/RequiredManagerUpgradeable.sol';
import './StorageSlots.sol';
import './AssetTokenGlobalModule.sol';
import './CurationTokenGlobalModule.sol';

struct TokenFeeConfig {
    uint256 createFee;
    uint256 updateFee;
    uint256 collectFee;
}

struct TokenFeeConfigData {
    bool exist;
    uint256 createFee;
    uint256 updateFee;
    uint256 collectFee;
}

struct HubTokenFeeConfig {
    address token;
    uint256 createFee;
    uint256 updateFee;
    uint256 collectFee;
}

contract TokenGlobalModule is
    CurationTokenGlobalModule,
    AssetTokenGlobalModule,
    RequiredManagerUpgradeable,
    UpgradeableBase,
    ERC165Upgradeable
{
    event TokenChanged(address token);
    event RecipientChanged(address recipient);

    function initialize(address manager, address token, address recipient) external initializer {
        __UUPSUpgradeable_init();
        __ERC165_init();
        __RequiredManager_init(manager);
        StorageSlots.setToken(token);
        StorageSlots.setRecipient(recipient);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function _authorizeUpgrade(address) internal view virtual override {
        _requireAdmin();
    }

    function setToken(address token) external {
        _requireAdmin();
        StorageSlots.setToken(token);
        emit TokenChanged(token);
    }

    function setRecipient(address recipient) external {
        _requireAdmin();
        require(recipient != address(0), 'recipient should not be zero');
        StorageSlots.setRecipient(recipient);
        emit RecipientChanged(recipient);
    }

    function _requireAdmin() internal view virtual {
        require(_managerOwner() == _msgSender(), 'not owner');
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IAssetGlobalModule).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
