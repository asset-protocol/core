// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import {OwnableUpgradeable} from '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
// import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
// import {UpgradeableBase} from '../upgradeability/UpgradeableBase.sol';
// import {IModuleFactory, IAssetHubFactory} from './IFactory.sol';
// import {IAssetHub} from '../interfaces/IAssetHub.sol';
// import {IAssetHubManager, HubCreateData} from '../interfaces/IAssetHubManager.sol';

// struct AssetHubInfo {
//     address collectNFT;
//     address nftGatedModule;
//     address assetCreateModule;
//     address tokenCollectModule;
//     address feeCollectModule;
// }

// struct AssetHubImplData {
//     address assetHubFactory;
//     address tokenCollectModuleFactory;
//     address nftGatedModuleFactory;
//     address tokenAssetCreateModuleFactory;
//     address collectNFTFactory;
//     address feeCollectModuleFactory;
// }

// contract AssetHubManager is OwnableUpgradeable, UpgradeableBase {
//     struct AssetHubStorage {
//         AssetHubImplData implData;
//         mapping(string => address) namedHubs;
//         mapping(address => AssetHubInfo) assetHubs;
//     }

//     struct GlobalModuleStorage {
//         address _module;
//     }

//     struct HubCreatorNFTStorage {
//         address _hubCreatorNFT;
//     }
//     // keccak256(abi.encode(uint256(keccak256('manager.storage.hub')) - 1)) & ~bytes32(uint256(0xff))
//     bytes32 private constant HubStorageLocation =
//         0xcf77b6f9147e7c76fb90677c5145a761b25198608dedc1ade257465d1645b800;
//     //keccak256(abi.encode(uint256(keccak256('manager.storage.globalModule')) - 1)) & ~bytes32(uint256(0xff))
//     bytes32 private constant GlobalModuleLocation =
//         0x3b1ecc23ed53ca9af47d8e68d76e1cf236cadced5a6e7c8a314ea4fa37a53800;
//     //keccak256(abi.encode(uint256(keccak256('manager.storage.hubcreatorNFT')) - 1)) & ~bytes32(uint256(0xff))
//     bytes32 private constant HubCreatorNFTLocation =
//         0xffa88101cd370f699719567569be368264e840ee1b9016e9d5a1dcdab6d1d500;

//     event ManagerInitialized(address creatorNFT, address globalModule);
//     event AssetHubDeployed(address indexed admin, string name, address assetHub, AssetHubInfo data);
//     event GlobalModuleChanged(address globalModule);
//     event HubCreatorNFTChanged(address creatorNFT);

//     error NameHubExisted(string hubName);
//     error AssetHubNotExisted();
//     error NotCreator(address);

//     function initialize(
//         AssetHubImplData calldata data,
//         address creatorNFT_,
//         address globalModule_
//     ) external initializer {
//         __Ownable_init(_msgSender());
//         __UUPSUpgradeable_init();
//         __AssetHubManager_init(data, creatorNFT_, globalModule_);
//     }

//     function _getHubStorage() private pure returns (AssetHubStorage storage $) {
//         assembly {
//             $.slot := HubStorageLocation
//         }
//     }

//     function _getGlobalModuleStorage() private pure returns (GlobalModuleStorage storage $) {
//         assembly {
//             $.slot := GlobalModuleLocation
//         }
//     }

//     function _setGlobalModule(address module) private {
//         GlobalModuleStorage storage $ = _getGlobalModuleStorage();
//         $._module = module;
//     }

//     function _getHubCreatorNFT() private pure returns (HubCreatorNFTStorage storage $) {
//         assembly {
//             $.slot := HubCreatorNFTLocation
//         }
//     }

//     function _setHubCreatorNFT(address creatorNFT_) private {
//         HubCreatorNFTStorage storage $ = _getHubCreatorNFT();
//         $._hubCreatorNFT = creatorNFT_;
//     }

//     modifier onlyHubCreator() {
//         HubCreatorNFTStorage storage $ = _getHubCreatorNFT();
//         if (
//             $._hubCreatorNFT != address(0) && IERC721($._hubCreatorNFT).balanceOf(_msgSender()) == 0
//         ) {
//             revert NotCreator(_msgSender());
//         }
//         _;
//     }

//     function __AssetHubManager_init(
//         AssetHubImplData calldata data,
//         address hubCreatorNFT_,
//         address globalModule_
//     ) internal onlyInitializing {
//         AssetHubStorage storage $ = _getHubStorage();
//         $.implData = data;
//         _setHubCreatorNFT(hubCreatorNFT_);
//         _setGlobalModule(globalModule_);
//         emit ManagerInitialized(hubCreatorNFT_, globalModule_);
//     }

//     function version() external view virtual override returns (string memory) {
//         return '1.0.0';
//     }

//     function globalModule() public view virtual returns (address) {
//         return _getGlobalModuleStorage()._module;
//     }

//     function setGlobalModule(address gm) public onlyOwner {
//         _setGlobalModule(gm);
//         emit GlobalModuleChanged(gm);
//     }

//     function setHubCreatorNFT(address creatorNFT_) public onlyOwner {
//         _setHubCreatorNFT(creatorNFT_);
//         emit HubCreatorNFTChanged(creatorNFT_);
//     }

//     function creatorNFT() external view returns (address) {
//         HubCreatorNFTStorage storage $ = _getHubCreatorNFT();
//         return $._hubCreatorNFT;
//     }

//     function assetHubInfo(address hub) external view returns (AssetHubInfo memory) {
//         AssetHubStorage storage $ = _getHubStorage();
//         return $.assetHubs[hub];
//     }

//     function assetHubInfoByName(string calldata name) external view returns (AssetHubInfo memory) {
//         AssetHubStorage storage $ = _getHubStorage();
//         address hub = $.namedHubs[name];
//         return $.assetHubs[hub];
//     }

//     function factories() external view returns (AssetHubImplData memory) {
//         AssetHubStorage storage $ = _getHubStorage();
//         return $.implData;
//     }

//     function setFactories(AssetHubImplData calldata data) external {
//         AssetHubStorage storage $ = _getHubStorage();
//         if (data.assetHubFactory != address(0)) {
//             $.implData.assetHubFactory = data.assetHubFactory;
//         }
//         if (data.tokenCollectModuleFactory != address(0)) {
//             $.implData.tokenCollectModuleFactory = data.tokenCollectModuleFactory;
//         }
//         if (data.feeCollectModuleFactory != address(0)) {
//             $.implData.feeCollectModuleFactory = data.feeCollectModuleFactory;
//         }
//         if (data.nftGatedModuleFactory != address(0)) {
//             $.implData.nftGatedModuleFactory = data.nftGatedModuleFactory;
//         }
//         if (data.collectNFTFactory != address(0)) {
//             $.implData.collectNFTFactory = data.collectNFTFactory;
//         }
//         if (data.tokenAssetCreateModuleFactory != address(0)) {
//             $.implData.tokenAssetCreateModuleFactory = data.tokenAssetCreateModuleFactory;
//         }
//     }

//     function isHub(address hub) external view returns (bool) {
//         AssetHubStorage storage $ = _getHubStorage();
//         return $.assetHubs[hub].collectNFT != address(0);
//     }

//     function exitsName(string calldata name) public view returns (bool) {
//         AssetHubStorage storage $ = _getHubStorage();
//         return $.namedHubs[name] != address(0);
//     }

//     function deploy(HubCreateData calldata data) external onlyHubCreator returns (address) {
//         AssetHubStorage storage $ = _getHubStorage();
//         if ($.implData.assetHubFactory == address(0)) {
//             revert('AssetHubFactory: not initialized');
//         }
//         if (exitsName(data.name)) {
//             revert NameHubExisted(data.name);
//         }
//         return _deployHub(data);
//     }

//     function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

//     function _deployHub(HubCreateData calldata data) internal returns (address) {
//         AssetHubStorage storage $ = _getHubStorage();
//         address admin = data.admin;
//         if (admin == address(0)) {
//             admin = _msgSender();
//         }
//         address assetHub = IAssetHubFactory($.implData.assetHubFactory).createUUPSUpgradeable('');

//         AssetHubInfo memory info = AssetHubInfo({
//             tokenCollectModule: _deployUUPSUpgradeableModule(
//                 assetHub,
//                 $.implData.tokenCollectModuleFactory
//             ),
//             nftGatedModule: _deployUUPSUpgradeableModule(
//                 assetHub,
//                 $.implData.nftGatedModuleFactory
//             ),
//             feeCollectModule: _deployUUPSUpgradeableModule(
//                 assetHub,
//                 $.implData.feeCollectModuleFactory
//             ),
//             assetCreateModule: data.createModule,
//             collectNFT: _deployUUPSUpgradeableModule(assetHub, $.implData.collectNFTFactory)
//         });
//         $.assetHubs[assetHub] = info;
//         $.namedHubs[data.name] = assetHub;
//         address[] memory collectModule = new address[](2);
//         collectModule[0] = info.tokenCollectModule;
//         collectModule[1] = info.feeCollectModule;
//         IAssetHub(assetHub).initialize(
//             data.name,
//             address(this),
//             admin,
//             info.collectNFT,
//             data.createModule,
//             collectModule
//         );

//         emit AssetHubDeployed(admin, data.name, assetHub, info);
//         return assetHub;
//     }

//     function _deployUUPSUpgradeableModule(address hub, address factory) internal returns (address) {
//         return IModuleFactory(factory).createUUPSUpgradeable(hub, new bytes(0));
//     }
// }
