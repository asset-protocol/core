// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from '@openzeppelin/contracts/token/ERC1155/ERC1155.sol';

contract TestERC1155 is ERC1155 {
    constructor() ERC1155('') {}

    function mint(address to, uint256 tokenId, uint256 amount) external {
        return _mint(to, tokenId, amount, '');
    }
}
