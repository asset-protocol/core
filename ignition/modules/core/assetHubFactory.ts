import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";

export const assethubFactoryModule = buildModule(Contracts.AssetHubFactory, (m) => {
  const assethubFactory = m.contract(Contracts.AssetHubFactory, [], {
    id: Contracts.AssetHubFactory,
    libraries: {
      "contracts/base/AssetHubLogic.sol:AssetHubLogic": m.contract(Contracts.AssetHubLogic, [])
    }
  });
  return { assethubFactory };
});

export const assethubManagerModule = buildModule(Contracts.AssetHubManager, (m) => {
  const assetHubManagerImpl = m.contract(Contracts.AssetHubManager, [], {
    id: Contracts.AssetHubManager + "_impl",
  });
  const assethubManagerProxy = m.contract("UpgradeableProxy", [assetHubManagerImpl, "0x"], {
    id: Contracts.AssetHubManager + "_proxy",
  })
  const assethubManager = m.contractAt(Contracts.AssetHubManager, assethubManagerProxy)
  const { assethubFactory } = m.useModule(assethubFactoryModule);
  const feeCollectModuleFactory = m.contract(Contracts.FeeCollectModuleFactory, []);
  const nftGatedModuleFactory = m.contract(Contracts.NftAssetGatedModuleFactory, []);
  const feeCreateAssetModuleFactory = m.contract(Contracts.FeeCreateAssetModuleFactory, [])
  const collectNFTFactory = m.contract(Contracts.CollectNFTFactory, [])

  m.call(assethubManager, "initialize", [
    [
      assethubFactory,
      feeCollectModuleFactory,
      nftGatedModuleFactory,
      feeCreateAssetModuleFactory,
      collectNFTFactory
    ]]);
  return { assethubManager, assethubManagerProxy };
});

export const deployAssetHubModule = buildModule("DeployAssetHub", (m) => {
  const deployer = m.getAccount(0);
  const { assethubManager } = m.useModule(assethubManagerModule)
  m.call(assethubManager, "deploy", [[deployer, "DeSchool", true]])
  return { assethubManager }
})