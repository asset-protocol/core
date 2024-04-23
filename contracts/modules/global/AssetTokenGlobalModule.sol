// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/interfaces/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {AssetTokenFeeConfig, StorageSlots, TokenConfig} from './StorageSlots.sol';
import {IAssetGlobalModule} from '../../interfaces/IAssetGlobalModule.sol';
import {DataTypes} from '../../libs/DataTypes.sol';

contract AssetTokenGlobalModule is IAssetGlobalModule {
    using SafeERC20 for IERC20;

    function setAssetDefaultConfig(AssetTokenFeeConfig calldata feeConfig) external {
        StorageSlots.setAssetDefaultConfig(feeConfig);
    }

    function setAssetHubConfig(address hub, AssetTokenFeeConfig calldata feeConfig) external {
        StorageSlots.setAssetHubConfig(hub, feeConfig);
    }

    function setAssetCollectFee(address hub, uint256 collectFee) external {
        StorageSlots.setAssetCollectFee(hub, collectFee);
    }

    function setAssetCreateFee(address hub, uint256 createFee) external {
        StorageSlots.setAssetCreateFee(hub, createFee);
    }

    function setAssetUpdateFee(address hub, uint256 updateFee) external {
        StorageSlots.setAssetUpdateFee(hub, updateFee);
    }

    function onCreateAsset(
        address publisher,
        uint256 /*assetId*/,
        DataTypes.AssetCreateData calldata /*data*/
    ) external payable override {
        address hub = msg.sender;
        AssetTokenFeeConfig memory cfg = StorageSlots.getAssetConfig(hub);
        if (cfg.createFee > 0) {
            TokenConfig storage $ = StorageSlots.getTokenConfigStorage();
            require($._recipient != address(0), 'recipient should not be zero');
            IERC20($._token).transferFrom(publisher, $._recipient, cfg.createFee);
        }
    }

    function onCollectAsset(
        uint256 /*assetId*/,
        address /*publiser*/,
        address collector,
        bytes calldata /*data*/
    ) external payable override {
        address hub = msg.sender;
        AssetTokenFeeConfig memory cfg = StorageSlots.getAssetConfig(hub);
        if (cfg.collectFee > 0) {
            TokenConfig storage $ = StorageSlots.getTokenConfigStorage();
            require($._recipient != address(0), 'recipient should not be zero');
            IERC20($._token).transferFrom(collector, $._recipient, cfg.collectFee);
        }
    }

    function onUpdateAsset(address publisher, uint256 /*assetId */) external payable override {
        address hub = msg.sender;
        AssetTokenFeeConfig memory cfg = StorageSlots.getAssetConfig(hub);
        if (cfg.updateFee > 0) {
            TokenConfig storage $ = StorageSlots.getTokenConfigStorage();
            require($._recipient != address(0), 'recipient should not be zero');
            IERC20($._token).transferFrom(publisher, $._recipient, cfg.updateFee);
        }
    }
}
