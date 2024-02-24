// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {ICreateAssetModule} from '../../interfaces/ICreateAssetModule.sol';
import {RequiredHub} from '../../base/RequiredHub.sol';
import {Errors} from '../../libs/Errors.sol';

contract FeeCreateAssetModule is RequiredHub, Ownable, ICreateAssetModule {
    using SafeERC20 for IERC20;

    address public immutable ERC20_TOKEN;
    uint256 private amount;
    address private _account;

    error AccountNotSet();

    constructor(
        address hub,
        address erc20Token,
        address account
    ) RequiredHub(hub) Ownable(_msgSender()) {
        if (erc20Token == address(0)) revert Errors.InitParamsInvalid();
        ERC20_TOKEN = erc20Token;
        _account = account;
    }

    function getAccount() external view returns (address) {
        return _account;
    }

    function setAccount(address account) external onlyOwner {
        _account = account;
    }

    function getAmount() external view returns (uint256) {
        return amount;
    }

    function setAmount(uint256 _amount) external {
        amount = _amount;
    }

    function processCreate(
        address publisher,
        uint256 /*assetId*/,
        bytes calldata /* data */
    ) external override onlyHub returns (bytes memory) {
        if (amount == 0) {
            return '';
        }
        if (_account == address(0)) {
            revert AccountNotSet();
        }
        IERC20(ERC20_TOKEN).safeTransferFrom(_account, publisher, amount);
        return '';
    }
}
