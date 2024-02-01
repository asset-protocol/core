// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Ownable} from '@openzeppelin/contracts/access/Ownable.sol';
import {Clones} from '@openzeppelin/contracts/proxy/Clones.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {ERC721} from '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import {IERC721Metadata} from '@openzeppelin/contracts/interfaces/IERC721Metadata.sol';
import {IAssetHub} from '../interfaces/IAssetHub.sol';
import {ISubscribeNFT} from '../interfaces/ISubscriberNFT.sol';
import {ISubscribeModule} from '../interfaces/ISubscribeModule.sol';
import {AssetNFTBase} from '../base/AssetNFTBase.sol';
import {Events} from '../libs/Events.sol';
import {Errors} from '../libs/Errors.sol';
import {Constants} from '../libs/Constants.sol';
import {DataTypes} from '../libs/DataTypes.sol';

contract AssetHub is AssetNFTBase, Ownable, IAssetHub {
    address internal _subscribeNFTImpl;

    mapping(address => bool) internal _subscribeModuleWhitelisted;
    mapping(address => bool) internal _createModuleWhitelisted;

    error InvalidSubscribeNFTImpl();

    constructor(
        string memory name,
        string memory symbol,
        address admin
    ) AssetNFTBase(name, symbol) Ownable(admin) {}

    function setSubscribeNFTImpl(address subscribeNFTImpl) external onlyOwner {
        if (subscribeNFTImpl == address(0)) {
            revert InvalidSubscribeNFTImpl();
        }
        _subscribeNFTImpl = subscribeNFTImpl;
    }

    function createModuleWhitelist(address createModule, bool whitelist) external onlyOwner {
        _createModuleWhitelisted[createModule] = whitelist;
        emit Events.CreateModuleWhitelisted(createModule, whitelist, block.timestamp);
    }

    function isCreateModuleWhitelisted(address createModule) external view returns (bool) {
        return _createModuleWhitelisted[createModule];
    }

    function create(
        DataTypes.CreateAssetData calldata data
    ) external override(IAssetHub) whenNotPaused returns (uint256) {
        if (data.subscribeModule != address(0)) {
            if (!_subscribeModuleWhitelisted[data.subscribeModule]) {
                revert Errors.SubscribeModuleNotWhitelisted();
            }
        }
        if (data.createModule != address(0)) {
            if (!_createModuleWhitelisted[data.createModule]) {
                revert Errors.CreateModuleNotWhitelisted();
            }
        }
        address pb = data.publisher;
        if (pb != address(0)) {
            _checkOwner();
        } else {
            pb = _msgSender();
        }
        return _createAsset(pb, data);
    }

    function subscribeModuleWhitelist(address subscribeModule, bool whitelist) external onlyOwner {
        _subscribeModuleWhitelisted[subscribeModule] = whitelist;
        emit Events.SubscribeModuleWhitelisted(subscribeModule, whitelist, block.timestamp);
    }

    function isSubscribeModuleWhitelisted(address followModule) external view returns (bool) {
        return _subscribeModuleWhitelisted[followModule];
    }

    function subscribe(
        uint256 assetId,
        bytes calldata subscribeModuleData
    ) external override whenNotPaused returns (uint256) {
        _checkAssetId(assetId);
        address subscirbeNFT = _assets[assetId].subscribeNFT;
        address subscribeModule = _assets[assetId].subscribeModule;

        if (subscribeModule != address(0)) {
            if (!_subscribeModuleWhitelisted[subscribeModule]) {
                revert Errors.SubscribeModuleNotWhitelisted();
            }
            (bool res, string memory errMsg) = ISubscribeModule(subscribeModule).processSubscribe(
                msg.sender,
                ownerOf(assetId),
                assetId,
                subscribeModuleData
            );
            require(res, errMsg);
        }

        if (subscirbeNFT == address(0)) {
            subscirbeNFT = _deploySubscribeNFT(assetId, ownerOf(assetId));
            _assets[assetId].subscribeNFT = subscirbeNFT;
        }
        uint256 tokenId = ISubscribeNFT(subscirbeNFT).mint(msg.sender);
        _assets[assetId].subscriberCount++;
        emit Events.Subscribed(
            msg.sender,
            ownerOf(assetId),
            assetId,
            subscribeModuleData,
            block.timestamp
        );
        return tokenId;
    }

    function totalSubscribers(uint256 assetId) external view returns (uint256) {
        return _assets[assetId].subscriberCount;
    }

    function subscribedCount(uint256 assetId, address subscriber) external view returns (uint256) {
        if (subscriber == address(0)) {
            return 0;
        }
        address subscribeNFT = _assets[assetId].subscribeNFT;
        if (subscribeNFT == address(0)) {
            return 0;
        }
        return ISubscribeNFT(subscribeNFT).count(subscriber);
    }

    function subscribeNFTContract(uint256 assetId) external view returns (address) {
        return _assets[assetId].subscribeNFT;
    }

    function emitSubscribeNFTTransferEvent(
        address publiser,
        uint256 assetId,
        uint256 subscribeNFTId,
        address from,
        address to
    ) external override {
        address expectedSubscribeNFT = _assets[assetId].subscribeNFT;
        if (msg.sender != expectedSubscribeNFT) revert Errors.CallerNotSubscribeNFT();
        emit Events.SubscribeNFTTransferred(
            publiser,
            assetId,
            subscribeNFTId,
            from,
            to,
            block.timestamp
        );
    }

    function _deploySubscribeNFT(uint256 assetId, address publisher) private returns (address) {
        if (_subscribeNFTImpl == address(0)) {
            revert InvalidSubscribeNFTImpl();
        }
        address subscribeNFT = Clones.clone(_subscribeNFTImpl);
        string memory subscribeNFTName = string.concat(
            Strings.toString(assetId),
            Constants.SUBSCRIBE_NFT_NAME_SUFFIX
        );
        string memory subscribeNFTSymbol = string(
            abi.encodePacked(Strings.toString(assetId), Constants.COLLECT_NFT_SYMBOL_SUFFIX)
        );

        ISubscribeNFT(subscribeNFT).initialize(
            subscribeNFTName,
            subscribeNFTSymbol,
            publisher,
            assetId
        );
        emit Events.SubscribeNFTDeployed(assetId, subscribeNFT, block.timestamp);

        return subscribeNFT;
    }
}
