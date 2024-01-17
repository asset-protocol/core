// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721Base} from '../base/ERC721Base.sol';
import {ISubscribeNFT} from '../interfaces/ISubscriberNFT.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {Errors} from '../libs/Errors.sol';

contract SubscribeNFT is ERC721Base, ISubscribeNFT {
    address public immutable HUB;

    uint256 internal _assetId;
    address internal _publisher;
    uint256 internal _tokenIdCounter;

    bool private _initialized;

    constructor(address hub) {
        if (hub == address(0)) revert Errors.InitParamsInvalid();
        HUB = hub;
    }

    function initialize(
        string calldata name_,
        string calldata symbol_,
        address publisher_,
        uint256 assetId_
    ) external override {
        if (_initialized) revert Errors.Initialized();
        super.__ERC721_Init(name_, symbol_);
        _assetId = assetId_;
        _publisher = publisher_;
        _initialized = true;
    }

    function mint(address to) external override returns (uint256) {
        if (msg.sender != HUB) revert Errors.NotHub();
        unchecked {
            uint256 tokenId = ++_tokenIdCounter;
            _mint(to, tokenId);
            return tokenId;
        }
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        address owner = _ownerOf(tokenId);
        if (owner == address(0)) revert Errors.TokenDoesNotExist();
        return IAssetHub(HUB).tokenURI(_assetId);
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
        IAssetHub(HUB).emitSubscribeNFTTransferEvent(
            _publisher,
            _assetId,
            tokenId,
            previousOwner,
            to
        );
        return previousOwner;
    }

    function count(address subscriber) external view override returns (uint256) {
        return balanceOf(subscriber);
    }
}
