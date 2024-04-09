// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import 'hardhat/console.sol';

contract DebugTest {
    using Strings for uint256;

    function value() external pure {
        // keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.ERC721")) - 1)) & ~bytes32(uint256(0xff))
        //   bytes32 v = keccak256(abi.encode(uint256(keccak256('globalmodule.storage.token')) - 1)) &
        //      ~bytes32(uint256(0xff));
        //  console.log('value', uint256(v).toHexString());
    }
}
