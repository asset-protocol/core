// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ManagerSlots {
    struct GlobalModuleStorage {
        address _module;
    }

    struct HubCreatorNFTStorage {
        address _hubCreatorNFT;
    }

    struct CurationStorage {
        address _curation;
    }

    //keccak256(abi.encode(uint256(keccak256('hubmanager.storage.globalModule')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant GlobalModuleLocation =
        0xb11e7737a09596c7ad0cf238ccfd6ee738ca77c827cecfc496a5a67e5718a100;

    function getGlobalModuleStorage() private pure returns (GlobalModuleStorage storage $) {
        assembly {
            $.slot := GlobalModuleLocation
        }
    }

    function getGlobalModule() internal view returns (address) {
        return getGlobalModuleStorage()._module;
    }

    function setGlobalModule(address module) internal {
        GlobalModuleStorage storage $ = getGlobalModuleStorage();
        $._module = module;
    }

    //keccak256(abi.encode(uint256(keccak256('hubmanager.storage.hubcreatorNFT')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant HubCreatorNFTLocation =
        0x96acf1f47f8b7f0f769f9958bc2f7fd94eeaffa084eedde0072c1bd6355dff00;

    function getHubCreatorNFTStorage() private pure returns (HubCreatorNFTStorage storage $) {
        assembly {
            $.slot := HubCreatorNFTLocation
        }
    }

    function getHubCreatorNFT() internal view returns (address) {
        return getHubCreatorNFTStorage()._hubCreatorNFT;
    }

    function setHubCreatorNFT(address creatorNFT_) internal {
        HubCreatorNFTStorage storage $ = getHubCreatorNFTStorage();
        $._hubCreatorNFT = creatorNFT_;
    }

    //keccak256(abi.encode(uint256(keccak256('hubmanager.storage.creation')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant CurationLocation =
        0x48b6d39603fdc1965bfe3e11b7a4e072ef5f03182f75c1707488d1d21f660800;

    function getCurationStorage() private pure returns (CurationStorage storage $) {
        assembly {
            $.slot := CurationLocation
        }
    }

    function getCuration() internal view returns (address) {
        return getCurationStorage()._curation;
    }

    function setCuration(address curation) internal {
        getCurationStorage()._curation = curation;
    }
}
