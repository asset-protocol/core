// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721Base} from './ERC721Base.sol';
import {DataTypes} from '../libs/DataTypes.sol';
import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {Pausable} from '@openzeppelin/contracts/utils/Pausable.sol';

contract AssetNFTBase is ERC721, Pausable {
    mapping(uint256 => DataTypes.Asset) internal _assets;
    mapping(address => uint256[]) internal _publisherAssets;
    uint256 internal _assertCounter;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) Pausable() {}

    function count(address publisher) external view returns (uint256) {
        return _publisherAssets[publisher].length;
    }

    function _createAsset(
        DataTypes.CreateAssetData calldata data
    ) internal virtual returns (uint256) {
        address pub = msg.sender;
        if (data.publisher != address(0)) {
            pub = data.publisher;
        }
        uint256 assetId = ++_assertCounter;
        _mint(msg.sender, assetId);
        DataTypes.Asset memory asset = DataTypes.Asset({
            contentURI: data.contentURI,
            subscriberCount: 0,
            subscribeModule: data.subscribeModule,
            subscribeNFT: address(0),
            timestamp: block.timestamp
        });
        _assets[_assertCounter] = asset;
        _publisherAssets[pub].push(assetId);
        return assetId;
    }
}
