// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {ERC721URIStorageUpgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol';
import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';
import {WhitelistBase} from '../base/WhitlistBase.sol';

contract AssetHubCreatorNFT is
    OwnableUpgradeable,
    UpgradeableBase,
    WhitelistBase,
    ERC721URIStorageUpgradeable
{
    uint256 private _tokenCount;

    function initialize(string memory name, string memory symbol) external initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __ERC721_init(name, symbol);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function setWhitelist(address account, bool whitelist) external virtual onlyOwner {
        _setWhitelist(account, whitelist);
    }

    function setWhitelistBatch(
        address[] memory accounts,
        bool[] memory isWhitelisted
    ) external virtual onlyOwner {
        _setWhitelistBatch(accounts, isWhitelisted);
    }

    function mint() external virtual onlyWhitelisted returns (uint256) {
        uint256 tokenId = _tokenCount;
        _mint(_msgSender(), tokenId);
        unchecked {
            _tokenCount++;
        }
        return tokenId;
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external virtual onlyOwner {
        return _setTokenURI(tokenId, _tokenURI);
    }

    function airdrop(address[] calldata accounts) external virtual onlyOwner {
        for (uint i = 0; i < accounts.length; i++) {
            _mint(accounts[i], _tokenCount);
            unchecked {
                _tokenCount++;
            }
        }
    }
}
