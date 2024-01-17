// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

library DataTypes {
    enum ProtocolState {
        Normal,
        SubscribingPaused,
        Paused
    }

    struct CreateAssetData {
        address publisher;
        string contentURI;
        address subscribeModule;
        bytes subscribeModuleInitData;
    }

    struct Asset {
        string contentURI;
        uint256 subscriberCount;
        address subscribeModule;
        address subscribeNFT;
        uint timestamp;
    }
}
