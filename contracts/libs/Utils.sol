// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC165} from '@openzeppelin/contracts/utils/introspection/IERC165.sol';

library Utils {
    function checkSuportsInterface(address to, bytes4 interfaceId) internal view returns (bool) {
        try IERC165(to).supportsInterface(interfaceId) returns (bool supported) {
            return supported;
        } catch {
            return false;
        }
    }
}
