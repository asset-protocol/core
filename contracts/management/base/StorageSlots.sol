// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AssetHubInfo} from '../../interfaces/IAssetHubManager.sol';

struct LiteHubStorage {
    address collectNFT;
    mapping(string => address) namedHubs;
    mapping(address => address[]) creatorHubs;
    mapping(address => AssetHubInfo) assetHubs;
}

struct AddressValue {
    address _value;
}

library StorageSlots {
    uint internal constant IMPL_ASSETHUB = 0;
    uint internal constant IMPL_CREATE_MODULE_TOKEN = 1;
    uint internal constant IMPL_COLLECT_NFT = 2;
    uint internal constant IMPL_COLLECT_MODULE_FEE = 3;
    uint internal constant IMPL_COLLECT_MODULE_TOKEN = 4;
    uint internal constant IMPL_GATED_MODULE_NFT = 5;

    error NameHubExisted(string hubName);

    // keccak256(abi.encode(uint256(keccak256('litehubmanager.storage.hub')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant LiteHubStorageLocation =
        0x7b0d89468fa248526193f3c51084ebb179c923c0ada9da77d2ab222238e7df00;

    function getLiteHubStorage() internal pure returns (LiteHubStorage storage $) {
        assembly {
            $.slot := LiteHubStorageLocation
        }
    }

    function createHub(
        string memory name,
        address hub,
        address admin,
        AssetHubInfo memory hubInfo
    ) internal {
        LiteHubStorage storage $ = getLiteHubStorage();
        if (hasNamedHub(name)) {
            revert NameHubExisted(name);
        }
        $.namedHubs[name] = hub;
        $.assetHubs[hub] = hubInfo;
        $.creatorHubs[admin].push(hub);
    }

    function getLiteHub(address hub) internal view returns (AssetHubInfo memory) {
        LiteHubStorage storage $ = getLiteHubStorage();
        return $.assetHubs[hub];
    }

    function getLiteHubByName(string memory name) internal view returns (AssetHubInfo memory) {
        LiteHubStorage storage $ = getLiteHubStorage();
        return getLiteHub($.namedHubs[name]);
    }

    function hasNamedHub(string memory name) internal view returns (bool) {
        LiteHubStorage storage $ = getLiteHubStorage();
        return $.namedHubs[name] != address(0);
    }

    function hasHub(address hub) internal view returns (bool) {
        LiteHubStorage storage $ = getLiteHubStorage();
        return $.assetHubs[hub].tokenCollectModule != address(0);
    }

    // keccak256(abi.encode(uint256(keccak256('requiredmanager.storage.manager')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant RequredManagerStorageLocation =
        0x74d1d33903966ad51678bb2f0f5578909a881e3651326bb32a574dab6a5b4300;

    function getRequredManagerStorage() internal pure returns (AddressValue storage $) {
        assembly {
            $.slot := RequredManagerStorageLocation
        }
    }

    function getManager() internal view returns (address) {
        AddressValue storage $ = getRequredManagerStorage();
        return $._value;
    }

    function setManager(address manager) internal {
        AddressValue storage $ = getRequredManagerStorage();
        $._value = manager;
    }
}
