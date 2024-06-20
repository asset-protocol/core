// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import {IERC721Metadata} from '@openzeppelin/contracts/interfaces/IERC721Metadata.sol';
import {ICollectNFT} from './interfaces/ICollectNFT.sol';
import {IAssetHub} from './interfaces/IAssetHub.sol';
import {Errors} from './libs/Errors.sol';
import {RequiredManagerUpgradeable} from './management/base/RequiredManagerUpgradeable.sol';

contract CollectNFT is ERC721Upgradeable, RequiredManagerUpgradeable, ICollectNFT {
    address private _hub;
    uint256 private _assetId;
    address private _publisher;
    uint256 private _tokenIdCounter;

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address manager_,
        address publisher_,
        uint256 assetId_
    ) external initializer {
        __ERC721_init(name_, symbol_);
        __RequiredManager_init(manager_);
        _checkHub(_msgSender());
        _assetId = assetId_;
        _publisher = publisher_;
        _hub = msg.sender;
    }

    modifier onlyCurrentHub() {
        if (msg.sender != _hub) {
            revert Errors.NotHub();
        }
        _;
    }

    function mint(address to) external override onlyCurrentHub returns (uint256) {
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _mint(to, tokenId);
            return tokenId;
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) revert Errors.TokenDoesNotExist();
        return IERC721Metadata(_hub).tokenURI(_assetId);
    }

    function getAssetInfo() external view returns (address, uint256) {
        return (_publisher, _assetId);
    }

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        address previousOwner = super._update(to, tokenId, auth);
        IAssetHub(_hub).emitCollectNFTTransferEvent(
            _publisher,
            _assetId,
            tokenId,
            previousOwner,
            to
        );
        return previousOwner;
    }

    function count(address collector) external view override returns (uint256) {
        return balanceOf(collector);
    }
}
