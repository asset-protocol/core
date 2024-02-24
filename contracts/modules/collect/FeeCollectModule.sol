// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ICollectModule} from '../../interfaces/ICollectModule.sol';
import {ITokenTransfer} from '../../interfaces/ITokenTransfer.sol';
import {Errors} from '../../libs/Errors.sol';
import {IAssetHub} from '../../interfaces/IAssetHub.sol';
import {IERC20} from '@openzeppelin/contracts/interfaces/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

struct FeeConfig {
    address currency;
    address recipient;
    uint256 amount;
}

contract FeeCollectModule is ICollectModule {
    using SafeERC20 for IERC20;

    address public immutable HUB;

    mapping(uint256 assetId => FeeConfig config) internal _feeConfig;

    error FeeConfigNotValid();

    constructor(address hub) {
        if (hub == address(0)) revert Errors.InitParamsInvalid();
        HUB = hub;
    }

    modifier onlyHub() {
        if (msg.sender != HUB) revert Errors.NotHub();
        _;
    }

    function setFeeConfig(uint256 assetId, FeeConfig memory feeConfig) external onlyHub {
        if (feeConfig.amount == 0) {
            // no fee, currency must be address(0)
            require(feeConfig.currency == address(0), 'FeeCollectModule: invalid fee config');
        }
        _feeConfig[assetId] = feeConfig;
    }

    function initialModule(
        address /* publisher */,
        uint256 assetId,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        FeeConfig memory feeConfig = abi.decode(data, (FeeConfig));
        if (feeConfig.amount == 0) {
            // no fee, currency must be address(0)
            require(feeConfig.currency == address(0), 'FeeCollectModule: invalid fee config');
        }
        _feeConfig[assetId] = feeConfig;
        return '';
    }

    function processCollect(
        address collector,
        address /* publisher */,
        uint256 assetId,
        bytes calldata
    ) external override onlyHub returns (bytes memory errMsg) {
        FeeConfig memory config = _feeConfig[assetId];
        if (config.amount == 0) {
            return '';
        }
        if (config.currency == address(0) || config.recipient == address(0)) {
            revert FeeConfigNotValid();
        }
        IERC20(config.currency).transferFrom(collector, config.recipient, config.amount);
        return '';
    }

    function getFeeConfig(uint256 assetId) external view returns (FeeConfig memory) {
        FeeConfig memory config = _feeConfig[assetId];
        if (config.currency == address(0) && config.amount == 0 && config.recipient == address(0)) {
            revert FeeConfigNotValid();
        }
        return config;
    }
}
