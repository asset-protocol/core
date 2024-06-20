// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DataTypes} from '../libs/DataTypes.sol';
import {IERC7572} from '../interfaces/IERC7572.sol';

struct ERC7572Storage {
    string uri;
}

abstract contract ERC7572 is IERC7572 {
    // keccak256(abi.encode(uint256(keccak256('erc7572.contract.uri')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ERC7572StorageLocation =
        0xa9e37aa47dce7322b17c50586406ecf816a6d6f96a12d13b4ffe448f22f00d00;

    function getUriStorage() internal pure returns (ERC7572Storage storage $) {
        assembly {
            $.slot := ERC7572StorageLocation
        }
    }

    function contractURI() external view virtual returns (string memory) {
        return getUriStorage().uri;
    }

    function _setContractURI(string memory uri) internal virtual {
        getUriStorage().uri = uri;
        emit ContractURIUpdated();
    }
}
