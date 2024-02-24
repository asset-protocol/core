// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IERC1155} from '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import {ERC165Upgradeable} from '@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol';
import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {UUPSUpgradeable} from '@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol';
import {IAssetGatedModule} from '../../interfaces/IAssetGatedModule.sol';
import {RequiredHubUpgradeable} from '../../base/RequiredHubUpgradeable.sol';

struct NftGatedConfig {
    address nftContract;
    uint256 tokenId;
    uint256 amount;
    bool isOr;
}

contract NftAssetGatedModule is
    OwnableUpgradeable,
    UUPSUpgradeable,
    RequiredHubUpgradeable,
    ERC165Upgradeable,
    IAssetGatedModule
{
    bytes4 public constant ERC721_INTERFACE = type(IERC721).interfaceId;
    bytes4 public constant ERC1155_INTERFACE = type(IERC1155).interfaceId;

    mapping(uint256 => NftGatedConfig[]) internal nftGatedConfigs;

    function initialize(address hub, address admin) external initializer {
        __Ownable_init(admin);
        __UUPSUpgradeable_init();
        __RequiredHub_init(hub);
    }

    function setConfig(uint256 assetId, NftGatedConfig[] calldata config) external onlyOwner {
        _setConfig(assetId, config);
    }

    function getConfig(uint256 assetId) public view returns (NftGatedConfig[] memory) {
        return nftGatedConfigs[assetId];
    }

    function initialModule(
        address /* publisher */,
        uint256 assetId,
        bytes calldata data
    ) external onlyHub returns (bytes memory) {
        NftGatedConfig[] memory config = abi.decode(data, (NftGatedConfig[]));
        if (config.length == 0) {
            return '';
        }
        _setConfig(assetId, config);
        return '';
    }

    function isGated(uint256 assetId, address account) external view override returns (bool) {
        NftGatedConfig[] memory config = nftGatedConfigs[assetId];
        if (config.length == 0) {
            return true;
        }
        for (uint256 i = 0; i < config.length; i++) {
            bool isOr = i == 0 ? false : config[i].isOr;
            bool isPass;
            if (_isERC721(config[i].nftContract)) {
                isPass = IERC721(config[i].nftContract).balanceOf(account) > 0;
            } else if (_isERC1155(config[i].nftContract)) {
                isPass =
                    IERC1155(config[i].nftContract).balanceOf(account, config[i].tokenId) >=
                    config[i].amount;
            }
            if (isOr && isPass) {
                return true;
            } else if (!isOr && !isPass) {
                return false;
            }
        }
        return true;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function _checkNftContract(address nftContract) internal view {
        require(nftContract != address(0), 'NftAssetGatedModule: nftContract is zero address');
        require(
            IERC721(nftContract).supportsInterface(ERC721_INTERFACE) ||
                IERC1155(nftContract).supportsInterface(ERC1155_INTERFACE),
            'NftAssetGatedModule: nftContract is not ERC721 or IERC1155'
        );
    }
    
    function _setConfig(uint256 assetId, NftGatedConfig[] memory config) internal {
        for (uint256 i = 0; i < config.length; i++) {
            _checkNftContract(config[i].nftContract);
        }
        for (uint256 i = 0; i < config.length; i++) {
            nftGatedConfigs[assetId].push(config[i]);
        }
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return
            interfaceId == type(IAssetGatedModule).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _isERC721(address nftContract) internal view returns (bool) {
        return IERC721(nftContract).supportsInterface(ERC721_INTERFACE);
    }

    function _isERC1155(address nftContract) internal view returns (bool) {
        return IERC1155(nftContract).supportsInterface(ERC1155_INTERFACE);
    }
}
