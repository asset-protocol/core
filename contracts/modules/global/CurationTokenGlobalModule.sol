// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/interfaces/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {CurationTokenFeeConfig, StorageSlots, TokenConfig} from './StorageSlots.sol';
import {ICurationGlobalModule, CurationAsset} from '../../curation/Interfaces.sol';
import {RequiredManagerUpgradeable} from '../../management/base/RequiredManagerUpgradeable.sol';

abstract contract CurationTokenGlobalModule is RequiredManagerUpgradeable, ICurationGlobalModule {
    using SafeERC20 for IERC20;

    function setCurationConfig(CurationTokenFeeConfig calldata feeConfig) external {
        StorageSlots.setCurationConfig(feeConfig);
    }

    function curationConfig() external view returns (CurationTokenFeeConfig memory) {
        return StorageSlots.getCurationConfig();
    }

    function setCurationCollectFee(uint256 collectFee) external onlyManagerOwnwer {
        StorageSlots.setCurationCollectFee(collectFee);
    }

    function setCurationCreateFee(uint256 createFee) external onlyManagerOwnwer {
        StorageSlots.setCurationCreateFee(createFee);
    }

    function setCurationUpdateFee(uint256 updateFee) external onlyManagerOwnwer {
        StorageSlots.setCurationUpdateFee(updateFee);
    }

    function onCurationCreate(
        address  publisher ,
        uint256 /* curationId */,
        address /* hub */,
        string memory /*curationURI*/,
        uint8 /*status*/,
        CurationAsset[] calldata /*assets*/
    ) external payable virtual override {
        CurationTokenFeeConfig memory cfg = StorageSlots.getCurationConfig();
        if (cfg.createFee > 0) {
            TokenConfig storage $ = StorageSlots.getTokenConfigStorage();
            require($._recipient != address(0), 'recipient should not be zero');
            IERC20($._token).transferFrom(publisher, $._recipient, cfg.createFee);
        }
    }

    function onCurationCollect(
        address publisher,
        uint256 curationId,
        address hub,
        address collector,
        bytes calldata data
    ) external {}
}
