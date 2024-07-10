// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IERC20Metadata} from '@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {Errors} from '../libs/Errors.sol';
import {ITokenTransfer} from '../interfaces/ITokenTransfer.sol';
import {Errors} from '../libs/Errors.sol';

contract TokenTransfer is ITokenTransfer {
    using SafeERC20 for IERC20;

    address public immutable HUB;
    mapping(address => bool) internal verifiedErc20Currencies;

    event erc20CurrencyRegistered(
        address indexed erc20CurrencyAddress,
        string name,
        string symbol,
        uint8 decimals,
        uint256 timestamp
    );

    error Erc20CurrencyNotVerified();

    constructor(address hub) {
        if (hub == address(0)) revert Errors.InitParamsInvalid();
        HUB = hub;
    }

    modifier onlyHub() {
        if (msg.sender != HUB) revert Errors.NotHub();
        _;
    }

    function verifyErc20Currency(
        address currency
    ) external override returns (bool registrationWasPerformed) {
        return _verifyErc20Currency(currency);
    }

    function safeSendErc20From(
        address currency,
        address from,
        uint256 amount
    ) external override onlyHub {
        _transferErc20From(currency, from, address(this), amount);
    }

    function safeSendErc20(address currency, address to, uint256 amount) external override onlyHub {
        _transferErc20From(currency, address(this), to, amount);
    }

    function safeTransferErc20From(
        address currency,
        address from,
        address to,
        uint256 amount
    ) external override onlyHub {
        _transferErc20From(currency, from, to, amount);
    }

    function _transferErc20From(
        address currency,
        address from,
        address to,
        uint256 amount
    ) internal {
        require(currency != address(0), 'TokenTransfer: currency is zero address');
        _verifyErc20Currency(currency);
        require(to != address(0), 'TokenTransfer: recipient is zero address');
        require(from != address(0), 'TokenTransfer: sender is zero address');
        if (amount == 0) {
            return;
        }
        IERC20(currency).safeTransferFrom(from, to, amount);
    }

    function _verifyErc20Currency(
        address currencyAddress
    ) internal returns (bool registrationWasPerformed) {
        if (verifiedErc20Currencies[currencyAddress]) {
            return false;
        } else {
            uint8 decimals = IERC20Metadata(currencyAddress).decimals();
            string memory name = IERC20Metadata(currencyAddress).name();
            string memory symbol = IERC20Metadata(currencyAddress).symbol();
            emit erc20CurrencyRegistered(currencyAddress, name, symbol, decimals, block.timestamp);
            verifiedErc20Currencies[currencyAddress] = true;
            return true;
        }
    }
}
