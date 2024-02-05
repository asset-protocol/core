// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721Base} from './ERC721Base.sol';
import {DataTypes} from '../libs/DataTypes.sol';
import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Pausable} from '@openzeppelin/contracts/utils/Pausable.sol';
import {IERC4906} from '@openzeppelin/contracts/interfaces/IERC4906.sol';
import {Errors} from '../libs/Errors.sol';
import {Events} from '../libs/Events.sol';

contract AssetNFTBase is ERC721, Pausable, IERC4906 {
    mapping(uint256 => DataTypes.Asset) internal _assets;
    mapping(address => uint256[]) internal _publisherAssets;
    uint256 internal _assertCounter;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) Pausable() {}

    function count(address publisher) external view returns (uint256) {
        return _publisherAssets[publisher].length;
    }

    function _createAsset(
        address publisher,
        DataTypes.CreateAssetData calldata data
    ) internal virtual returns (uint256) {
        address pub = publisher;
        if (pub == address(0)) {
            revert Errors.NoAssetPublisher();
        }

        uint256 assetId = ++_assertCounter;
        _mint(pub, assetId);
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

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        _checkAssetId(tokenId);
        return _assets[tokenId].contentURI;
    }

    function setTokenURI(uint256 assetId, string calldata contentURI) external {
        _checkAssetId(assetId);
        if (_ownerOf(assetId) != _msgSender()) {
            revert Errors.NotAssetPublisher();
        }
        _assets[assetId].contentURI = contentURI;
        emit MetadataUpdate(assetId);
    }

    function _checkAssetId(uint256 assetId) internal view {
        if (_ownerOf(assetId) == address(0)) revert Errors.AssetDoesNotExist();
    }
}
