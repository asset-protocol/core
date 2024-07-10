// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import {IAssetHub} from '../../interfaces/IAssetHub.sol';
// import {IAssetHubManager} from '../../interfaces/IAssetHubManager.sol';
// import {StorageSlots} from './StorageSlots.sol';

// abstract contract RequiredManager {
//     error NotManager();
//     error NotHub();
//     error NotHubOwner();

//     constructor(address manager) {
//         StorageSlots.setManager(manager);
//     }

//     modifier onlyManager() {
//         if (msg.sender != StorageSlots.getManager()) {
//             revert NotManager();
//         }
//         _;
//     }

//     modifier onlyHub() {
//         bool isHub = IAssetHubManager(StorageSlots.getManager()).isHub(msg.sender);
//         if (!isHub) {
//             revert NotHub();
//         }
//         _;
//     }

//     function _checkHubOwner(address hub, address account) internal view {
//         if (hub == account) {
//             return;
//         }
//         if (IAssetHub(hub).hubOwner() != account) {
//             revert NotHubOwner();
//         }
//     }

//     function _checkAssetOwner(address hub, uint256 assetId, address account) internal view {
//         if (IAssetHub(hub).assetPublisher(assetId) != account) {
//             revert NotHubOwner();
//         }
//     }
// }
