import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";
import { ZeroAddress } from "ethers";

export const assethubFactoryModule = buildModule(Contracts.AssetHubFactory, (m) => {
  const assethubFactory = m.contract(Contracts.AssetHubFactory, [], {
    id: Contracts.AssetHubFactory,
    libraries: {
      "AssetHubLogic": m.library(Contracts.AssetHubLogic)
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
  const assethubManager = m.contractAt(Contracts.AssetHubManager, assethubManagerProxy);
  return { assethubManager, assethubManagerProxy };
});

export const assethubManagerInitModule = buildModule(Contracts.AssetHubManager + "Init", (m) => {
  const { assethubManager } = m.useModule(assethubManagerModule);
  const { assethubFactory } = m.useModule(assethubFactoryModule);
  const tokenCollectModuleFactory = m.contract(Contracts.TokenCollectModuleFactory, []);
  const nftGatedModuleFactory = m.contract(Contracts.NftAssetGatedModuleFactory, []);
  const tokenAssetCreateModuleFactory = m.contract(Contracts.TokenAssetCreateModuleFactory, [])
  const feeCollectModuleFactory = m.contract(Contracts.FeeCollectModuleFactory, [])
  const collectNFTFactory = m.contract(Contracts.CollectNFTFactory, []);
  const feeTokenGlobalModuleFactory = m.contract(Contracts.TokenGlobalModuleFactory, []);

  m.call(assethubManager, "initialize", [
    [
      assethubFactory,
      tokenCollectModuleFactory,
      nftGatedModuleFactory,
      tokenAssetCreateModuleFactory,
      collectNFTFactory,
      feeCollectModuleFactory
    ], feeTokenGlobalModuleFactory]);
  return { assethubManager };
});

export const deployAssetHubModule = buildModule("DeployAssetHub", (m) => {
  const deployer = m.getAccount(0);
  const { assethubManager } = m.useModule(assethubManagerModule)
  m.call(assethubManager, "deploy", [[deployer, "TEST", true, ZeroAddress]])
  return { assethubManager }
})