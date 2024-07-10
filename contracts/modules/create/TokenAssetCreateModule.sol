// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {ICreateAssetModule} from '../../interfaces/ICreateAssetModule.sol';
import {RequiredHub} from '../../base/RequiredHub.sol';
import {Errors} from '../../libs/Errors.sol';

struct TokenCreateConfig {
    address tokenContract;
    uint256 amount;
    address account;
    bool isPay;
}

contract TokenAssetCreateModule is RequiredHub, ICreateAssetModule {
    using SafeERC20 for IERC20;

    TokenCreateConfig _config;

    event ConfigChanged(address hub, TokenCreateConfig config);

    error HubNotSet();
    error AccountNotSet();

    constructor(address hub) RequiredHub(hub) {}

    function setConfig(TokenCreateConfig calldata config) external onlyHubOwner {
        _checkConfig(config);
        _config = TokenCreateConfig({
            tokenContract: config.tokenContract,
            amount: config.amount,
            account: config.account,
            isPay: config.isPay
        });
        emit ConfigChanged(HUB, config);
    }

    function getConfig() external view returns (TokenCreateConfig memory) {
        return _config;
    }

    function processCreate(
        address publisher,
        uint256 /*assetId*/,
        bytes calldata /* data */
    ) external override onlyHub returns (bytes memory) {
        if (_config.tokenContract == address(0)) {
            revert HubNotSet();
        }
        if (_config.isPay) {
            IERC20(_config.tokenContract).safeTransferFrom(
                publisher,
                _config.account,
                _config.amount
            );
        } else {
            IERC20(_config.tokenContract).safeTransferFrom(
                _config.account,
                publisher,
                _config.amount
            );
        }
        return '';
    }

    function _checkConfig(TokenCreateConfig calldata config) internal pure {
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
