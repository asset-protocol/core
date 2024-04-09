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
    uint256 createFee;
    uint256 updateFee;
    uint256 collectFee;
}

struct TokenFeeConfigData {
    bool exist;
    uint256 createFee;
    uint256 updateFee;
    uint256 collectFee;
}

struct HubTokenFeeConfig {
    address token;
    uint256 createFee;
    uint256 updateFee;
    uint256 collectFee;
}

contract TokenGlobalModule is IGlobalModule, UpgradeableBase, OwnableUpgradeable {
    using SafeERC20 for IERC20;
    struct TokenGlobalModuleStorage {
        address _manager;
        address _token;
        address _recipient;
        mapping(address => TokenFeeConfigData) _hubConfigs;
    }
    // keccak256(abi.encode(uint256(keccak256('globalmodule.storage.token')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TokenStorageLocation =
        0xcf77b6f9147e7c76fb90677c5145a761b25198608dedc1ade257465d1645b800;

    function _getTokenStorage() private pure returns (TokenGlobalModuleStorage storage $) {
        assembly {
            $.slot := TokenStorageLocation
        }
    }

    function initialize(
        address manager,
        address token,
        TokenFeeConfig calldata feeConfig
    ) external initializer {
        __UUPSUpgradeable_init();
        __Ownable_init(_msgSender());
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        $._hubConfigs[address(0)] = TokenFeeConfigData({
            exist: true,
            createFee: feeConfig.createFee,
            updateFee: feeConfig.updateFee,
            collectFee: feeConfig.collectFee
        });
        $._token = token;
        $._manager = manager;
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function _authorizeUpgrade(address) internal view virtual override {
        _requireAdmin();
    }

    function config(address hub) public view returns (HubTokenFeeConfig memory) {
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        TokenFeeConfigData memory c = _getConfig(hub);
        return
            HubTokenFeeConfig({
                token: $._token,
                createFee: c.createFee,
                updateFee: c.updateFee,
                collectFee: c.collectFee
            });
    }

    function setToken(address token) external {
        _requireAdmin();
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        $._token = token;
    }

    function setDefaultConfig(TokenFeeConfig memory feeConfig) external {
        _requireAdmin();
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        $._hubConfigs[address(0)] = TokenFeeConfigData({
            exist: true,
            createFee: feeConfig.createFee,
            updateFee: feeConfig.updateFee,
            collectFee: feeConfig.collectFee
        });
    }

    function setHubConfig(address hub, TokenFeeConfig calldata feeConfig) external {
        _requireAdmin();
        _checkHub(hub);
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        $._hubConfigs[hub] = TokenFeeConfigData({
            exist: true,
            collectFee: feeConfig.collectFee,
            createFee: feeConfig.createFee,
            updateFee: feeConfig.updateFee
        });
    }

    function setCollectFee(address hub, uint256 collectFee) external {
        _requireAdmin();
        _checkHub(hub);
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        $._hubConfigs[hub].exist = true;
        $._hubConfigs[hub].collectFee = collectFee;
    }

    function setCreateFee(address hub, uint256 createFee) external {
        _requireAdmin();
        _checkHub(hub);
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        $._hubConfigs[hub].exist = true;
        $._hubConfigs[hub].createFee = createFee;
    }

    function setUpdateFee(address hub, uint256 updateFee) external {
        _requireAdmin();
        _checkHub(hub);
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        $._hubConfigs[hub].exist = true;
        $._hubConfigs[hub].updateFee = updateFee;
    }

    function setRecipient(address recipient) external {
        _requireAdmin();
        require(recipient != address(0), 'recipient should not be zero');
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        $._recipient = recipient;
    }

    function onCreateAsset(
        address publisher,
        uint256 /*assetId*/,
        DataTypes.AssetCreateData calldata /*data*/
    ) external override {
        address hub = msg.sender;
        _checkHub(hub);
        TokenFeeConfigData memory c = _getConfig(hub);
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        if (c.createFee > 0) {
            require($._recipient != address(0), 'recipient should not be zero');
            IERC20($._token).transferFrom(publisher, $._recipient, c.createFee);
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
        TokenFeeConfigData memory c = _getConfig(hub);
        if (c.collectFee > 0) {
            TokenGlobalModuleStorage storage $ = _getTokenStorage();
            require($._recipient != address(0), 'recipient should not be zero');
            IERC20($._token).transferFrom(collector, $._recipient, c.collectFee);
        }
    }

    function onUpdate(address publisher, uint256 /*assetId */) external override {
        address hub = msg.sender;
        _checkHub(hub);
        TokenFeeConfigData memory c = _getConfig(hub);
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        if (c.updateFee > 0) {
            require($._recipient != address(0), 'recipient should not be zero');
            IERC20($._token).transferFrom(publisher, $._recipient, c.updateFee);
        }
    }

    function _getConfig(address hub) internal view returns (TokenFeeConfigData memory) {
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        TokenFeeConfigData memory c = $._hubConfigs[hub];
        if (!c.exist) {
            c = $._hubConfigs[address(0)];
        }
        require(c.exist, 'default fee config not set');
        return c;
    }

    function _requireAdmin() internal view virtual {
        TokenGlobalModuleStorage storage $ = _getTokenStorage();
        require(IOwnable($._manager).owner() == _msgSender(), 'not owner');
    }

    function _checkHub(address hub) internal pure {
        require(hub != address(0), 'hub should not be zero');
    }
}
