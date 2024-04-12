// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {ERC721Upgradeable} from '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';

struct AssetInfo {
    address hub;
    uint256 assetId;
    uint order;
}

struct CurationData {
    AssetInfo[] assets;
    string tokenURI;
    uint8 status;
}

contract Curation is OwnableUpgradeable, ERC721Upgradeable, UpgradeableBase {
    struct CurationStorage {
        uint256 _tokenCounter;
        mapping(uint256 => CurationData) _curations;
    }

    // keccak256(abi.encode(uint256(keccak256('curation.storage.info')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CurationStorageLocation =
        0x630988ce46de1e9d40f4a157e51f63ecc4f010353c5635d4c643ce648b328c00;

    function _getCurationStorage() private pure returns (CurationStorage storage $) {
        assembly {
            $.slot := CurationStorageLocation
        }
    }

    function initialize(string memory name, string memory symbol) external initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __ERC721_init(name, symbol);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner {}

    function version() external view virtual override returns (string memory) {
        return '0.0.1';
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        CurationStorage storage $ = _getCurationStorage();
        return $._curations[tokenId].tokenURI;
    }

    function create(CurationData calldata data) external virtual returns (uint256) {
        address publisher = _msgSender();
        CurationStorage storage $ = _getCurationStorage();
        uint256 tokenId = $._tokenCounter;
        _mint(publisher, tokenId);
        $._curations[tokenId] = data;
        unchecked {
            $._tokenCounter = tokenId + 1;
        }
        return tokenId;
    }

    function setStatus(uint256 id, uint8 status) external {
        _checkTokenOwner(id);
        CurationStorage storage $ = _getCurationStorage();
        $._curations[id].status = status;
    }

    function _checkTokenOwner(uint256 id) internal view {
        require(_ownerOf(id) == address(0), 'curation have not created');
        require(_ownerOf(id) == _msgSender(), 'require token owner');
    }
}
