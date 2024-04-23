// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct TokenConfig {
    address _token;
    address _recipient;
}

struct AssetTokenFeeConfig {
    bool exist;
    uint256 createFee;
    uint256 updateFee;
    uint256 collectFee;
}

struct CurationTokenFeeConfig {
    uint256 createFee;
    uint256 updateFee;
    uint256 collectFee;
}

library StorageSlots {
    /****** TokenConfigStorage *********/
    // keccak256(abi.encode(uint256(keccak256('tokenglobalmodule.storage.token')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant TokenConfigLocation =
        0x908b205a5e363af8c70216be9895814338c591b7ce7f77528b384cff4d398600;

    function getTokenConfigStorage() internal pure returns (TokenConfig storage $) {
        assembly {
            $.slot := TokenConfigLocation
        }
    }

    function setToken(address token) internal {
        TokenConfig storage $ = getTokenConfigStorage();
        $._token = token;
    }

    function setRecipient(address recipient) internal {
        TokenConfig storage $ = getTokenConfigStorage();
        $._recipient = recipient;
    }

    /****** AssetTokenStorage *********/

    struct AssetTokenStorage {
        mapping(address => AssetTokenFeeConfig) _configs;
    }

    // keccak256(abi.encode(uint256(keccak256('tokenglobalmodule.storage.asset')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant AssetTokenStorageLocation =
        0x094d7c90e327e3e4e48754cb85999a4c6f117b1cd7e4887e646216386bd3b300;

    function _getAssetTokenStorage() private pure returns (AssetTokenStorage storage $) {
        assembly {
            $.slot := AssetTokenStorageLocation
        }
    }

    function setAssetDefaultConfig(AssetTokenFeeConfig calldata config) internal {
        setAssetHubConfig(address(0), config);
    }

    function setAssetHubConfig(address hub, AssetTokenFeeConfig calldata config) internal {
        AssetTokenStorage storage $ = _getAssetTokenStorage();
        $._configs[hub] = AssetTokenFeeConfig({
            exist: true,
            createFee: config.createFee,
            updateFee: config.updateFee,
            collectFee: config.collectFee
        });
    }

    function setAssetCreateFee(address hub, uint256 fee) internal {
        AssetTokenStorage storage $ = _getAssetTokenStorage();
        $._configs[hub].exist = true;
        $._configs[hub].createFee = fee;
    }

    function setAssetUpdateFee(address hub, uint256 fee) internal {
        AssetTokenStorage storage $ = _getAssetTokenStorage();
        $._configs[hub].exist = true;
        $._configs[hub].updateFee = fee;
    }

    function setAssetCollectFee(address hub, uint256 fee) internal {
        AssetTokenStorage storage $ = _getAssetTokenStorage();
        $._configs[hub].exist = true;
        $._configs[hub].collectFee = fee;
    }

    function getAssetConfig(address hub) internal view returns (AssetTokenFeeConfig memory) {
        AssetTokenStorage storage $ = _getAssetTokenStorage();
        AssetTokenFeeConfig memory c = $._configs[hub];
        if (!c.exist) {
            c = $._configs[address(0)];
        }
        return c;
    }

    /****** CurationTokenStorage *********/

    struct CurationTokenStorage {
        CurationTokenFeeConfig _config;
    }

    // keccak256(abi.encode(uint256(keccak256('tokenglobalmodule.storage.curation')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CurationTokenStorageLocation =
        0x42afa9229e6f8aa6aa6b8dd7d5b99a5382e98277f14f3a4ee2ccc01badaf7500;

    function _getCurationTokenStorage() private pure returns (CurationTokenStorage storage $) {
        assembly {
            $.slot := CurationTokenStorageLocation
        }
    }

    function setCurationConfig(CurationTokenFeeConfig calldata config) internal {
        CurationTokenStorage storage $ = _getCurationTokenStorage();
        $._config = CurationTokenFeeConfig({
            createFee: config.createFee,
            updateFee: config.updateFee,
            collectFee: config.collectFee
        });
    }

    function setCurationCreateFee(uint256 fee) internal {
        CurationTokenStorage storage $ = _getCurationTokenStorage();
        $._config.createFee = fee;
    }

    function setCurationUpdateFee(uint256 fee) internal {
        CurationTokenStorage storage $ = _getCurationTokenStorage();
        $._config.updateFee = fee;
    }

    function setCurationCollectFee(uint256 fee) internal {
        CurationTokenStorage storage $ = _getCurationTokenStorage();
        $._config.collectFee = fee;
    }

    function getCurationConfig() internal view returns (CurationTokenFeeConfig memory) {
        CurationTokenStorage storage $ = _getCurationTokenStorage();
        return $._config;
    }
}
