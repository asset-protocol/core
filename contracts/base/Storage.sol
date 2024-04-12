// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {DataTypes} from '../libs/DataTypes.sol';

struct AssetNFTStorage {
    mapping(uint256 => DataTypes.Asset) _assets;
    mapping(address => uint256[]) _publisherAssets;
    uint256 _assertCounter;
}

library Storage {
    /******** AssetNFT *******/
    // keccak256(abi.encode(uint256(keccak256('assetnft.storage.asset')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AssetNFTStorageLocation =
        0x7e8514cbfe65e57e3d3aebb6c7016c16d29f1928a0f65b0f8adab1a709b70f00;

    function getAssetStorage() internal pure returns (AssetNFTStorage storage $) {
        assembly {
            $.slot := AssetNFTStorageLocation
        }
    }

    // keccak256(abi.encode(uint256(keccak256('assetnft.storage.collectWhitelist')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CollectModuleWhitelistStorageLocation =
        0x3b85697e44469f78e908156f3616d1d396edd9b75e6145af1f749ed14bccca00;

    function getCollectModuleWhitelistStorage()
        internal
        pure
        returns (mapping(address => bool) storage $)
    {
        assembly {
            $.slot := CollectModuleWhitelistStorageLocation
        }
    }

    /******** AssetHub _manager *******/
    struct ManagerStorage {
        address _manager;
    }

    // keccak256(abi.encode(uint256(keccak256('assetnft.storage.manager')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant ManagerStorageLocation =
        0x9355872fe51cc71787f0c76945e6cb928694d6d04d758eee381ace435776b200;

    function getManagerStorage() internal pure returns (ManagerStorage storage $) {
        assembly {
            $.slot := ManagerStorageLocation
        }
    }

    function setManager(address manager) internal {
        ManagerStorage storage $ = getManagerStorage();
        $._manager = manager;
    }

    function getManager() internal view returns (address) {
        ManagerStorage storage $ = getManagerStorage();
        return $._manager;
    }

    /******** AssetHub _collectNFTImpl *******/
    struct CollectNFTImplStorage {
        address _collectNFTImpl;
    }
    // keccak256(abi.encode(uint256(keccak256('assetnft.storage.collectnfgimpl')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CollectNFTImplLocation =
        0xa2019512ec89928a9751644c53b7c93602c8498f0c262be07849f48d5bcc3700;

    function getCollectNFTImplStorage() internal pure returns (CollectNFTImplStorage storage $) {
        assembly {
            $.slot := CollectNFTImplLocation
        }
    }

    function setCollectNFTImpl(address impl) internal {
        CollectNFTImplStorage storage $ = getCollectNFTImplStorage();
        $._collectNFTImpl = impl;
    }

    function getCollectNFTImpl() internal view returns (address) {
        CollectNFTImplStorage storage $ = getCollectNFTImplStorage();
        return $._collectNFTImpl;
    }

    /******** AssetHub _createAssetModule *******/
    struct CreateAssetModuleStorage {
        address _createAssetModule;
    }
    // keccak256(abi.encode(uint256(keccak256('assetnft.storage.createmodule')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CreateAssetModuleLocation =
        0xeb9fc2ca90c84b24c9e531188e69cd0a83ccdf4a740f74e0d68b089ac12d6000;

    function getCreateAssetModuleStorage()
        internal
        pure
        returns (CreateAssetModuleStorage storage $)
    {
        assembly {
            $.slot := CreateAssetModuleLocation
        }
    }

    function setCreateAssetModule(address module) internal {
        CreateAssetModuleStorage storage $ = getCreateAssetModuleStorage();
        $._createAssetModule = module;
    }

    function getCreateAssetModule() internal view returns (address) {
        CreateAssetModuleStorage storage $ = getCreateAssetModuleStorage();
        return $._createAssetModule;
    }

    /*--------- AssetNFT --------*/
}
