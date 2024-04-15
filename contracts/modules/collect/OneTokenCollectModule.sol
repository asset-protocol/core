// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {OneCollectModuleBaseUpgradeable} from './base/OneCollectModuleBaseUpgradeable.sol';
import {Version} from '../../upgradeability/UpgradeableBase.sol';
import {ITokenTransfer} from '../../interfaces/ITokenTransfer.sol';
import {Errors} from '../../libs/Errors.sol';
import {IAssetHub} from '../../interfaces/IAssetHub.sol';
import {IERC20} from '@openzeppelin/contracts/interfaces/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';

struct TokenCollectConfig {
    address currency;
    address recipient;
    uint256 amount;
}

contract OneTokenCollectModule is Version, OneCollectModuleBaseUpgradeable {
    using SafeERC20 for IERC20;

    mapping(address => mapping(uint256 assetId => TokenCollectConfig config)) internal _config;

    event TokenConfigChanged(
        address indexed hub,
        uint256 indexed assetId,
        TokenCollectConfig config
    );

    error TokenConfigNotValid();
    error InvalidRecipient();

    function initialize(address manager) external initializer {
        __OneCollectModuleBaseUpgradeable_init(manager);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function setConfig(address hub, uint256 assetId, TokenCollectConfig memory config) external {
        _checkAssetOwner(hub, assetId, msg.sender);
        _setConfigig(hub, assetId, config);
    }

    function initialModule(
        address /* publisher */,
        uint256 assetId,
        bytes calldata data
    ) external override onlyHub returns (bytes memory) {
        address hub = _msgSender();
        TokenCollectConfig memory config = abi.decode(data, (TokenCollectConfig));
        _setConfigig(hub, assetId, config);
        return '';
    }

    function processCollect(
        address collector,
        address /* publisher */,
        uint256 assetId,
        bytes calldata
    ) external payable override onlyHub returns (bytes memory errMsg) {
        address hub = _msgSender();
        TokenCollectConfig storage config = _config[hub][assetId];
        if (config.amount == 0) {
            return '';
        }
        address recipient = config.recipient;
        if (config.recipient == address(0)) {
            recipient = IAssetHub(hub).assetPublisher(assetId);
        }
        if (recipient == address(0)) {
            revert InvalidRecipient();
        }
        IERC20(config.currency).transferFrom(collector, recipient, config.amount);
        return '';
    }

    function getConfig(
        address hub,
        uint256 assetId
    ) external view returns (TokenCollectConfig memory) {
        TokenCollectConfig memory config = _config[hub][assetId];
        if (config.currency == address(0) && config.amount == 0 && config.recipient == address(0)) {
            revert TokenConfigNotValid();
        }
        return config;
    }

    function _setConfigig(address hub, uint256 assetId, TokenCollectConfig memory config) internal {
        _checkConfig(config);
        _config[hub][assetId] = config;
        emit TokenConfigChanged(hub, assetId, config);
    }

    function _checkConfig(TokenCollectConfig memory config) internal pure {
        if (config.amount == 0) {
            // no token, currency must be address(0)
            require(config.currency == address(0), 'TokenCollectModule: invalid token config');
        }
    }
}
