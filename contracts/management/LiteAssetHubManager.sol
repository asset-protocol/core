// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {IAssetHubManager, HubCreateData} from '../interfaces/IAssetHubManager.sol';
import {LiteHubManagerBase, MangerInitData} from './base/LiteHubManagerBase.sol';
import {ManagerSlots} from './ManagerSlots.sol';

contract LiteAssetHubManager is
    LiteHubManagerBase,
    UpgradeableBase,
    OwnableUpgradeable,
    IAssetHubManager
{
    error NameHubExisted(string hubName);
    error AssetHubNotExisted();
    error NotCreator(address);

    function initialize(
        MangerInitData calldata data,
        address creatorNFT_,
        address globalModule_,
        address curation_
    ) external initializer {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __AssetHubManager_init(data, creatorNFT_, globalModule_, curation_);
    }

    modifier onlyHubCreator() {
        address nft = ManagerSlots.getHubCreatorNFT();
        if (nft != address(0) && IERC721(nft).balanceOf(_msgSender()) == 0) {
            revert NotCreator(_msgSender());
        }
        _;
    }

    function __AssetHubManager_init(
        MangerInitData calldata data,
        address hubCreatorNFT_,
        address globalModule_,
        address curation_
    ) internal onlyInitializing {
        __LiteHubManagerBase_init(data);
        setHubCreatorNFT(hubCreatorNFT_);
        setGlobalModule(globalModule_);
        setCuration(curation_);
    }

    function version() external view virtual override returns (string memory) {
        return '1.0.0';
    }

    function isHub(address hub) external view returns (bool) {
        return _isHub(hub);
    }

    function globalModule() public view virtual returns (address) {
        return ManagerSlots.getGlobalModule();
    }

    function setGlobalModule(address gm) public onlyOwner {
        ManagerSlots.setGlobalModule(gm);
        emit GlobalModuleChanged(gm);
    }

    function creatorNFT() external view returns (address) {
        return ManagerSlots.getHubCreatorNFT();
    }

    function setHubCreatorNFT(address creatorNFT_) public onlyOwner {
        ManagerSlots.setHubCreatorNFT(creatorNFT_);
        emit HubCreatorNFTChanged(creatorNFT_);
    }

    function curation() external view returns (address) {
        return ManagerSlots.getCuration();
    }

    function setCuration(address curation_) public onlyOwner {
        ManagerSlots.setCuration(curation_);
        emit CurationUpdated(curation_);
    }

    function deploy(HubCreateData calldata data) external onlyHubCreator returns (address) {
        address hub = _createHub(data);
        return hub;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
