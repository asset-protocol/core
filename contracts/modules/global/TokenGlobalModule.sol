// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {IERC20} from '@openzeppelin/contracts/interfaces/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IGlobalModule} from '../../interfaces/IGlobalModule.sol';
import {IOwnable} from '../../interfaces/IOwnable.sol';
import {DataTypes} from '../../libs/DataTypes.sol';
import {UpgradeableBase} from '../../upgradeability/UpgradeableBase.sol';

struct TokenFeeConfig {
    uint256 collectFee;
    uint256 createFee;
    uint256 updateFee;
}

struct TokenFeeConfigData {
    bool exist;
    uint256 collectFee;
    uint256 createFee;
    uint256 updateFee;
}

contract TokenGlobalModule is IGlobalModule, UpgradeableBase, OwnableUpgradeable {
    address private _manager;
    address private _token;
    address _recipient;
    mapping(address => TokenFeeConfigData) _hubConfigs;

    using SafeERC20 for IERC20;

    function initialize(
        address manager,
        address token,
        TokenFeeConfig calldata feeConfig
    ) external initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(_msgSender());
        _hubConfigs[address(0)] = TokenFeeConfigData(
            true,
            feeConfig.collectFee,
            feeConfig.collectFee,
            feeConfig.updateFee
        );
        _token = token;
        _manager = manager;
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function _authorizeUpgrade(address) internal view virtual override {
        _requireAdmin();
    }

    function config(address hub) public view returns (TokenFeeConfigData memory) {
        TokenFeeConfigData memory c = _hubConfigs[hub];
        if (!c.exist) {
            c = _hubConfigs[address(0)];
        }
        require(c.exist, 'default fee config not set');
        return c;
    }

    function setToken(address token) external {
        _requireAdmin();
        _token = token;
    }

    function setDefaultConfig(TokenFeeConfig memory feeConfig) external {
        _requireAdmin();
        _hubConfigs[address(0)] = TokenFeeConfigData(
            true,
            feeConfig.collectFee,
            feeConfig.collectFee,
            feeConfig.updateFee
        );
    }

    function setHubConfig(address hub, TokenFeeConfig calldata feeConfig) external {
        _requireAdmin();
        _checkHub(hub);
        _hubConfigs[hub] = TokenFeeConfigData({
            exist: true,
            collectFee: feeConfig.collectFee,
            createFee: feeConfig.createFee,
            updateFee: feeConfig.updateFee
        });
    }

    function setCollectFee(address hub, uint256 collectFee) external {
        _requireAdmin();
        _checkHub(hub);
        _hubConfigs[hub].exist = true;
        _hubConfigs[hub].collectFee = collectFee;
    }

    function setCreateFee(address hub, uint256 createFee) external {
        _requireAdmin();
        _checkHub(hub);
        _hubConfigs[hub].exist = true;
        _hubConfigs[hub].createFee = createFee;
    }

    function setUpdateFee(address hub, uint256 updateFee) external {
        _requireAdmin();
        _checkHub(hub);
        _hubConfigs[hub].exist = true;
        _hubConfigs[hub].updateFee = updateFee;
    }

    function setRecipient(address recipient) external {
        _requireAdmin();
        require(recipient != address(0), 'recipient should not be zero');
        _recipient = recipient;
    }

    function onCreateAsset(
        address publisher,
        uint256 /*assetId*/,
        DataTypes.AssetCreateData calldata /*data*/
    ) external override {
        address hub = msg.sender;
        _checkHub(hub);
        TokenFeeConfigData memory c = config(hub);
        if (c.createFee > 0) {
            require(_recipient != address(0), 'recipient should not be zero');
            IERC20(_token).transferFrom(publisher, _recipient, c.createFee);
        }
    }

    function onCollect(
        uint256 /*assetId*/,
        address /*publiser*/,
        address collector,
        bytes calldata /*data*/
    ) external override {
        address hub = msg.sender;
        _checkHub(hub);
        TokenFeeConfigData memory c = config(hub);
        if (c.collectFee > 0) {
            require(_recipient != address(0), 'recipient should not be zero');
            IERC20(_token).transferFrom(collector, _recipient, c.collectFee);
        }
    }

    function onUpdate(address publisher, uint256 /*assetId */) external override {
        address hub = msg.sender;
        _checkHub(hub);
        TokenFeeConfigData memory c = config(hub);
        if (c.updateFee > 0) {
            require(_recipient != address(0), 'recipient should not be zero');
            IERC20(_token).transferFrom(publisher, _recipient, c.updateFee);
        }
    }

    function _requireAdmin() internal view virtual {
        require(IOwnable(_manager).owner() == _msgSender(), 'not owner');
    }

    function _checkHub(address hub) internal pure {
        require(hub != address(0), 'hub should not be zero');
    }
}
