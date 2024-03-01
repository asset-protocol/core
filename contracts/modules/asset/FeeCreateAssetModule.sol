// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {ICreateAssetModule} from '../../interfaces/ICreateAssetModule.sol';
import {RequiredHub} from '../../base/RequiredHub.sol';
import {IOwnable} from '../../interfaces/IOwnable.sol';
import {Errors} from '../../libs/Errors.sol';

struct FeeCreateAssetConfig {
    address tokenContract;
    uint256 amount;
    address account;
    bool isPay;
}

contract FeeCreateAssetModule is ICreateAssetModule {
    using SafeERC20 for IERC20;

    mapping(address => FeeCreateAssetConfig) _configs;

    event ConfigChanged(address hub, FeeCreateAssetConfig config);

    error HubNotSet();
    error AccountNotSet();
    error NotHubOwner();

    function setConfig(address hub, FeeCreateAssetConfig calldata config) external {
        _checkHubOwner(hub, msg.sender);
        _checkConfig(config);
        _configs[hub] = FeeCreateAssetConfig({
            tokenContract: config.tokenContract,
            amount: config.amount,
            account: config.account,
            isPay: config.isPay
        });
        emit ConfigChanged(hub, config);
    }

    function getConfig(address hub) external view returns (FeeCreateAssetConfig memory) {
        return _configs[hub];
    }

    function processCreate(
        address publisher,
        uint256 /*assetId*/,
        bytes calldata /* data */
    ) external override returns (bytes memory) {
        FeeCreateAssetConfig storage config = _configs[msg.sender];
        if (config.tokenContract == address(0)) {
            revert HubNotSet();
        }
        if (config.isPay) {
            IERC20(config.tokenContract).safeTransferFrom(publisher, config.account, config.amount);
        } else {
            IERC20(config.tokenContract).safeTransferFrom(config.account, publisher, config.amount);
        }
        return '';
    }

    function _checkHubOwner(address hub, address account) internal view {
        if (hub == account) {
            return;
        }
        if (IOwnable(hub).owner() != account) {
            revert NotHubOwner();
        }
    }

    function _checkConfig(FeeCreateAssetConfig calldata config) internal pure {
        if (config.tokenContract == address(0)) {
            revert HubNotSet();
        }
        if (config.amount == 0) {
            return;
        }
        if (config.account == address(0)) {
            revert AccountNotSet();
        }
    }
}
