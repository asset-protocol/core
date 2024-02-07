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
import {ITokenTransfer} from '../interfaces/ITokenTransfer.sol';
import {AssetNFTBase} from '../base/AssetNFTBase.sol';
import {Events} from '../libs/Events.sol';
import {Errors} from '../libs/Errors.sol';
import {Constants} from '../libs/Constants.sol';
import {DataTypes} from '../libs/DataTypes.sol';

contract AssetHub is AssetNFTBase, Ownable, IAssetHub {
    bool private _initialized;
    address internal _subscribeNFTImpl;
    address internal _defaultToken;
    address internal _tokenTransfer;

    mapping(address => bool) internal _subscribeModuleWhitelisted;

    error InvalidSubscribeNFTImpl();

    constructor(
        string memory name,
        string memory symbol,
        address admin
    ) AssetNFTBase(name, symbol) Ownable(admin) {}

    function initialize(
        address subscribeNFT,
        address tokenTransfer,
        address defaultToken
    ) external {
        if (tokenTransfer == address(0)) {
            revert Errors.InitParamsInvalid();
        }
        _tokenTransfer = tokenTransfer;

        if (subscribeNFT == address(0)) {
            revert InvalidSubscribeNFTImpl();
        }
        _subscribeNFTImpl = subscribeNFT;
        _defaultToken = defaultToken;
        _initialized = true;
    }

    function create(
        DataTypes.CreateAssetData calldata data
    ) external override(IAssetHub) whenNotPaused returns (uint256) {
        if (data.subscribeModule != address(0)) {
            if (!_subscribeModuleWhitelisted[data.subscribeModule]) {
                revert Errors.SubscribeModuleNotWhitelisted();
            }
        }

        address pb = data.publisher;
        address sender = address(0);
        if (pb != address(0)) {
            _checkOwner();
            sender = owner(); // use owner as the sender
        } else {
            pb = _msgSender();
            sender = pb;
        }
        uint256 res = _createAsset(pb, data);
        ITokenTransfer(_tokenTransfer).safeTransferErc20From(_defaultToken, sender, pb, 100);
        return res;
    }

    function subscribeModuleWhitelist(
        address subscribeModule,
        bool whitelist
    ) external whenNotPaused onlyOwner {
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
            ISubscribeModule(subscribeModule).processSubscribe(
                msg.sender,
                ownerOf(assetId),
                assetId,
                subscribeModuleData
            );
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

    function getTokenTransfer() external view override returns (address) {
        return _tokenTransfer;
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
