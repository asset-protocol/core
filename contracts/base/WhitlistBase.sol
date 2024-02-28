// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Context} from '@openzeppelin/contracts/utils/Context.sol';

abstract contract WhitelistBase {
    mapping(address => bool) private _whitelist;

    event Whitelisted(address indexed account, bool isWhitelisted);
    error NotWhitelisted(address account);

    modifier onlyWhitelisted() {
        _checkWhitelisted(msg.sender);
        _;
    }

    function whitelisted(address account) public view virtual returns (bool) {
        return _whitelist[account];
    }

    function _setWhitelist(address account, bool whitelist) internal virtual {
        _whitelist[account] = whitelist;
        emit Whitelisted(account, whitelist);
    }

    function _setWhitelistBatch(
        address[] memory accounts,
        bool[] memory isWhitelisted
    ) internal virtual {
        for (uint256 i = 0; i < accounts.length; i++) {
            _setWhitelist(accounts[i], isWhitelisted[i]);
        }
    }

    function _checkWhitelisted(address account) internal view {
        if (!whitelisted(account)) {
            revert NotWhitelisted(account);
        }
    }
}
