// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {RequiredHub} from '../base/RequiredHub.sol';

interface IAssetGatedModule {
  
  function initialModule(
        address publisher,
        uint256 assetId,
        bytes calldata data
    ) external returns (bytes memory);

    function isGated(uint256 assetId, address account) external view returns (bool);
}
