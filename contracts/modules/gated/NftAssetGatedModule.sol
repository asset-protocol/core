// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IERC1155} from '@openzeppelin/contracts/token/ERC1155/IERC1155.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {ERC165Upgradeable} from '@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol';
import {Version} from '../../upgradeability/UpgradeableBase.sol';
import {INftAssetGatedModule} from '../../interfaces/INftAssetGatedModule.sol';
import {IAssetGatedModule} from '../../interfaces/IAssetGatedModule.sol';
import {RequiredManagerUpgradeable} from '../../management/base/RequiredManagerUpgradeable.sol';
import {Utils} from '../../libs/Utils.sol';

enum NftGatedType {
    ERC20,
    ERC721,
    ERC1155
}

struct NftGatedConfig {
    address nftContract;
    NftGatedType nftType;
    uint256 tokenId;
    uint256 amount;
    bool isOr;
}

contract NftAssetGatedModule is
    Version,
    RequiredManagerUpgradeable,
    ERC165Upgradeable,
    INftAssetGatedModule
{
    bytes4 public constant ERC721_INTERFACE = type(IERC721).interfaceId;
    bytes4 public constant ERC1155_INTERFACE = type(IERC1155).interfaceId;
    bytes4 public constant ERC20_INTERFACE = type(IERC20).interfaceId;

    mapping(address => mapping(uint256 => NftGatedConfig[])) internal _nftGatedConfigs;

    event ConfigChanged(address indexed hub, uint256 indexed assetId, NftGatedConfig[] config);

    error NftContractIsZeroAddress();
    error ContractTypeNotSupported(address);
    error ContractTypeNotMatched(address, NftGatedType);

    function initialize(address manager) external initializer {
        __RequiredManager_init(manager);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function setConfig(address hub, uint256 assetId, NftGatedConfig[] calldata config) external {
        _checkAssetOwner(hub, assetId, msg.sender);
        _setConfig(hub, assetId, config);
    }

    function getConfig(address hub, uint256 assetId) public view returns (NftGatedConfig[] memory) {
        return _nftGatedConfigs[hub][assetId];
    }

    function initialModule(
        address /* publisher */,
        uint256 assetId,
        bytes calldata data
    ) external onlyHub returns (bytes memory) {
        address hub = _msgSender();
        NftGatedConfig[] memory config = abi.decode(data, (NftGatedConfig[]));
        if (config.length == 0) {
            return '';
        }
        _setConfig(hub, assetId, config);
        return '';
    }

    function isGated(
        uint256 assetId,
        address account
    ) external view override onlyHub returns (bool) {
        address hub = _msgSender();
        NftGatedConfig[] memory config = _nftGatedConfigs[hub][assetId];
        if (config.length == 0) {
            return true;
        }
        for (uint256 i = 0; i < config.length; i++) {
            bool isOr = i == 0 ? false : config[i].isOr;
            bool isPass;
            if (config[i].nftType == NftGatedType.ERC20) {
                isPass = IERC20(config[i].nftContract).balanceOf(account) >= config[i].amount;
            } else if (config[i].nftType == NftGatedType.ERC721) {
                isPass = IERC721(config[i].nftContract).balanceOf(account) >= config[i].amount;
            } else if (config[i].nftType == NftGatedType.ERC1155) {
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

    function _checkNftContract(NftGatedConfig memory config) internal view {
        if (config.nftContract == address(0)) {
            revert NftContractIsZeroAddress();
        }
        if (config.nftType == NftGatedType.ERC20) {
            // if (!Utils.checkSuportsInterface(config.nftContract, ERC20_INTERFACE)) {
            //     revert ContractTypeNotMatched(config.nftContract, config.nftType);
            // }
        } else if (config.nftType == NftGatedType.ERC721) {
            if (!Utils.checkSuportsInterface(config.nftContract, ERC721_INTERFACE)) {
                revert ContractTypeNotMatched(config.nftContract, config.nftType);
            }
        } else if (config.nftType == NftGatedType.ERC1155) {
            if (!Utils.checkSuportsInterface(config.nftContract, ERC1155_INTERFACE)) {
                revert ContractTypeNotMatched(config.nftContract, config.nftType);
            }
        } else {
            revert ContractTypeNotSupported(config.nftContract);
        }
    }

    function _setConfig(address hub, uint256 assetId, NftGatedConfig[] memory config) internal {
        for (uint256 i = 0; i < config.length; i++) {
            _checkNftContract(config[i]);
        }
        for (uint256 i = 0; i < config.length; i++) {
            _nftGatedConfigs[hub][assetId].push(config[i]);
        }
        emit ConfigChanged(hub, assetId, config);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return
            interfaceId == type(IAssetGatedModule).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
