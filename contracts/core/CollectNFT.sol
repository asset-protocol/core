// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import {ICollectNFT} from '../interfaces/ICollectNFT.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {IERC721Metadata} from '@openzeppelin/contracts/interfaces/IERC721Metadata.sol';
import {Errors} from '../libs/Errors.sol';

contract CollectNFT is ERC721Upgradeable, ICollectNFT {
    address public immutable HUB;
    uint256 internal _assetId;
    address internal _publisher;
    uint256 internal _tokenIdCounter;

    constructor(address hub) {
        if (hub == address(0)) revert Errors.InitParamsInvalid();
        HUB = hub;
    }

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address publisher_,
        uint256 assetId_
    ) external initializer {
        __ERC721_init(name_, symbol_);
        _assetId = assetId_;
        _publisher = publisher_;
    }

    modifier onlyHub() {
        if (msg.sender != HUB) {
            revert Errors.NotHub();
        }
        _;
    }

    function mint(address to) external override onlyHub returns (uint256) {
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _mint(to, tokenId);
            return tokenId;
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) revert Errors.TokenDoesNotExist();
        return IERC721Metadata(HUB).tokenURI(_assetId);
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
        IAssetHub(HUB).emitCollectNFTTransferEvent(
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
