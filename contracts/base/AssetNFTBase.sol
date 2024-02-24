// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DataTypes} from '../libs/DataTypes.sol';
import {ERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import {IERC4906} from '@openzeppelin/contracts/interfaces/IERC4906.sol';
import {IERC165} from '@openzeppelin/contracts/interfaces/IERC165.sol';
import {PausableUpgradeable} from '@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol';
import {Errors} from '../libs/Errors.sol';
import {Events} from '../libs/Events.sol';

contract AssetNFTBase is ERC721Upgradeable, PausableUpgradeable, IERC4906 {
    mapping(uint256 => DataTypes.Asset) internal _assets;
    mapping(address => uint256[]) internal _publisherAssets;
    uint256 internal _assertCounter;

    function __AssetNFTBase_init(
        string memory name_,
        string memory symbol_
    ) internal onlyInitializing {
        __ERC721_init(name_, symbol_);
        __Pausable_init();
    }

    function count(address publisher) external view returns (uint256) {
        return _publisherAssets[publisher].length;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Upgradeable, IERC165) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function _createAsset(
        address publisher,
        DataTypes.AssetCreateData calldata data
    ) internal virtual returns (uint256) {
        address pub = publisher;
        if (pub == address(0)) {
            revert Errors.NoAssetPublisher();
        }

        uint256 assetId = ++_assertCounter;
        _mint(pub, assetId);
        DataTypes.Asset memory asset = DataTypes.Asset({
            contentURI: data.contentURI,
            collectCount: 0,
            collectModule: data.collectModule,
            collectNFT: address(0),
            gatedModule: data.gatedModule,
            timestamp: block.timestamp
        });

        _assets[_assertCounter] = asset;
        _publisherAssets[pub].push(assetId);
        return assetId;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721Upgradeable) returns (string memory) {
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
        emit Events.AssetMetadataUpdate(assetId, contentURI, block.timestamp);
    }

    function _checkAssetId(uint256 assetId) internal view {
        if (_ownerOf(assetId) == address(0)) revert Errors.AssetDoesNotExist();
    }

    function _requireAssetPublisher(uint256 assetId, address account) internal view {
        if (_ownerOf(assetId) != account) {
            revert Errors.NotAssetPublisher();
        }
    }
}
