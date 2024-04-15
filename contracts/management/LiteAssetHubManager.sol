// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';
import {IModuleFactory, IAssetHubFactory} from './IFactory.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {IAssetHubManager, HubCreateData} from '../interfaces/IAssetHubManager.sol';
import {LiteHubManagerBase, MangerInitData} from './base/LiteHubManagerBase.sol';
import {LiteHubInfo, StorageSlots} from './base/StorageSlots.sol';

contract LiteAssetHubManager is
    LiteHubManagerBase,
    UpgradeableBase,
    OwnableUpgradeable,
    IAssetHubManager
{
    struct GlobalModuleStorage {
        address _module;
    }

    struct HubCreatorNFTStorage {
        address _hubCreatorNFT;
    }

    //keccak256(abi.encode(uint256(keccak256('litemanager.storage.globalModule')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant GlobalModuleLocation =
        0x64e2b410897138a6f5c7a5e2e03f974e84ef5399ef2f06dd988b7537a1b7db00;
    //keccak256(abi.encode(uint256(keccak256('litemanager.storage.hubcreatorNFT')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant HubCreatorNFTLocation =
        0x6379e760cb0bdd76bb584747d291e2b390678acabc2e6dc84a5887a3927f7200;

    event ManagerInitialized(address creatorNFT, address globalModule);
    event GlobalModuleChanged(address globalModule);
    event HubCreatorNFTChanged(address creatorNFT);

    error NameHubExisted(string hubName);
    error AssetHubNotExisted();
    error NotCreator(address);

    function initialize(
        MangerInitData calldata data,
        address creatorNFT_,
        address globalModule_
    ) external initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __AssetHubManager_init(data, creatorNFT_, globalModule_);
    }

    function _getGlobalModuleStorage() private pure returns (GlobalModuleStorage storage $) {
        assembly {
            $.slot := GlobalModuleLocation
        }
    }

    function _setGlobalModule(address module) private {
        GlobalModuleStorage storage $ = _getGlobalModuleStorage();
        $._module = module;
    }

    function _getHubCreatorNFT() private pure returns (HubCreatorNFTStorage storage $) {
        assembly {
            $.slot := HubCreatorNFTLocation
        }
    }

    function _setHubCreatorNFT(address creatorNFT_) private {
        HubCreatorNFTStorage storage $ = _getHubCreatorNFT();
        $._hubCreatorNFT = creatorNFT_;
    }

    modifier onlyHubCreator() {
        HubCreatorNFTStorage storage $ = _getHubCreatorNFT();
        if (
            $._hubCreatorNFT != address(0) && IERC721($._hubCreatorNFT).balanceOf(_msgSender()) == 0
        ) {
            revert NotCreator(_msgSender());
        }
        _;
    }

    function __AssetHubManager_init(
        MangerInitData calldata data,
        address hubCreatorNFT_,
        address globalModule_
    ) internal onlyInitializing {
        __LiteHubManagerBase_init(data);
        _setHubCreatorNFT(hubCreatorNFT_);
        _setGlobalModule(globalModule_);
        emit ManagerInitialized(hubCreatorNFT_, globalModule_);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function isHub(address hub) external view returns (bool) {
        return StorageSlots.hasHub(hub);
    }

    function globalModule() public view virtual returns (address) {
        return _getGlobalModuleStorage()._module;
    }

    function setGlobalModule(address gm) public onlyOwner {
        _setGlobalModule(gm);
        emit GlobalModuleChanged(gm);
    }

    function setHubCreatorNFT(address creatorNFT_) public onlyOwner {
        _setHubCreatorNFT(creatorNFT_);
        emit HubCreatorNFTChanged(creatorNFT_);
    }

    function creatorNFT() external view returns (address) {
        HubCreatorNFTStorage storage $ = _getHubCreatorNFT();
        return $._hubCreatorNFT;
    }

    function deploy(HubCreateData calldata data) external onlyHubCreator returns (address) {
        address hub = _createHub(data);
        return hub;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
