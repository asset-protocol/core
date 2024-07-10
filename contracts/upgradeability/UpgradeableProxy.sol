// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// We import these here to force Hardhat to compile them.
// This ensures that their artifacts are available for Hardhat Ignition to use.
// import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {ERC1967Proxy} from '@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol';

contract UpgradeableProxy is ERC1967Proxy {
    constructor(address implementation, bytes memory data) ERC1967Proxy(implementation, data) {}
}
