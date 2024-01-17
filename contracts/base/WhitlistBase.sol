// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";

abstract contract WhitelistBase is Context {
    mapping(address => bool) private _whitelist;

    event Whitelisted(address indexed account, bool isWhitelisted);

    constructor() {
        _whitelist[_msgSender()] = true;
        emit Whitelisted(_msgSender(), true);
    }

    function isWhitelisted(address account) public view virtual returns (bool) {
        return _whitelist[account];
    }

    function _addWhitelist(address account) internal virtual {
        _whitelist[account] = true;
        emit Whitelisted(account, true);
    }

    function _addWhitelistBatch(address[] memory accounts) internal virtual {
        for (uint256 i = 0; i < accounts.length; i++) {
            _addWhitelist(accounts[i]);
        }
    }

    function _removeWhitelist(address account) internal virtual {
        _whitelist[account] = false;
        emit Whitelisted(account, false);
    }

    function _removeWhitelistBatch(address[] memory accounts) internal virtual {
        for (uint256 i = 0; i < accounts.length; i++) {
            _removeWhitelist(accounts[i]);
        }
    }
}
