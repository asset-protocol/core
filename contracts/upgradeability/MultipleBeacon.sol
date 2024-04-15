// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultipleBeacon {
    struct BeaconStorage {
        mapping(uint => address) _implementations;
    }

    error BeaconInvalidImplementation(address implementation);

    event Upgraded(address indexed implementation);

    // keccak256(abi.encode(uint256(keccak256('multiplebeacon.storage.impl')) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant BeaconStorageLocation =
        0x45fab50dbb228cdf1d8d863db151a35fd0b4c607524cf00178b754a0c4c42d00;

    function getBeaconStorage() internal pure returns (BeaconStorage storage $) {
        assembly {
            $.slot := BeaconStorageLocation
        }
    }

    function implementation(uint index) public view virtual returns (address) {
        BeaconStorage storage $ = getBeaconStorage();
        return $._implementations[index];
    }

    function _upgradeTo(uint index, address newImplementation) internal virtual {
        if (newImplementation.code.length == 0) {
            revert BeaconInvalidImplementation(newImplementation);
        }
        BeaconStorage storage $ = getBeaconStorage();
        $._implementations[index] = newImplementation;
    }
}
