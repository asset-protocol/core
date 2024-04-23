// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from '@openzeppelin/contracts/interfaces/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {CurationTokenFeeConfig, StorageSlots, TokenConfig} from './StorageSlots.sol';
import {ICurationGlobalModule, CurationAsset} from '../../curation/Interfaces.sol';

contract CurationTokenGlobalModule is ICurationGlobalModule {
    using SafeERC20 for IERC20;

    function setCurationConfig(CurationTokenFeeConfig calldata feeConfig) external {
        StorageSlots.setCurationConfig(feeConfig);
    }

    function setCurationCollectFee(uint256 collectFee) external {
        StorageSlots.setCurationCollectFee(collectFee);
    }

    function setCurationCreateFee(uint256 createFee) external {
        StorageSlots.setCurationCreateFee(createFee);
    }

    function setCurationUpdateFee(uint256 updateFee) external {
        StorageSlots.setCurationUpdateFee(updateFee);
    }

    function onCurationCreate(
        uint256 /* curationId */,
        address publisher,
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
        uint256 curationId,
        address publiser,
        address collector,
        bytes calldata data
    ) external {}
}
