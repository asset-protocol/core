// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {Errors} from '../libs/Errors.sol';
import {ITokenTransfer} from '../interfaces/ITokenTransfer.sol';
import {Errors} from '../libs/Errors.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

contract TokenTransfer is ITokenTransfer {
    using SafeERC20 for IERC20;

    address public immutable HUB;

    constructor(address hub) {
        if (hub == address(0)) revert Errors.InitParamsInvalid();
        HUB = hub;
    }

    modifier onlyHub() {
        if (msg.sender != HUB) revert Errors.NotHub();
        _;
    }

    function safeTransferERC20From(
        address currency,
        address from,
        uint256 amount
    ) external override onlyHub {
        _transferERC20From(currency, from, address(this), amount);
    }

    function safeTransferERC20(address currency, address to, uint256 amount) external onlyHub {
        _transferERC20From(currency, address(this), to, amount);
    }

    function _transferERC20From(address currency, address from, address to, uint256 amount) internal {
        if (amount == 0 || currency == address(0)) {
            return;
        }
        require(to != address(0), 'TokenTransfer: recipient is zero address');
        require(from != address(0), 'TokenTransfer: sender is zero address');
        IERC20(currency).safeTransferFrom(from, to, amount);
    }
}
