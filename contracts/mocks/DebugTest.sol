// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import 'hardhat/console.sol';

contract DebugTest {
    using Strings for uint256;

    function value() external pure {
        bytes32 v = keccak256(abi.encode(uint256(keccak256('curation.storage.info')) - 1)) &
            ~bytes32(uint256(0xff));
        console.log('value', uint256(v).toHexString());
    }
}
