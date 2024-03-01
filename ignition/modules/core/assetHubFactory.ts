import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";

export const assethubFactoryImplModule = buildModule(Contracts.AssetHubFactory + "_impl", (m) => {
  const assethubFactoryImpl = m.contract(Contracts.AssetHubFactory, [], {
    id: Contracts.AssetHubFactory + "_impl",
    libraries: {
      "contracts/base/AssetHubLogic.sol:AssetHubLogic": m.contract(Contracts.AssetHubLogic, [])
    }
  });
  return { assethubFactoryImpl };
});

export const assethubFactoryModule = buildModule(Contracts.AssetHubFactory, (m) => {
  const assetHubManagerImpl = m.contract(Contracts.AssetHubManager, [], {
    id: Contracts.AssetHubManager + "_impl",
  });
  const assethubFactoryProxy = m.contract("ERC1967Proxy", [assetHubManagerImpl, "0x"], {
    id: Contracts.AssetHubManager + "_proxy",
  })
  const assethubManager = m.contractAt(Contracts.AssetHubManager, assethubFactoryProxy)
  const { assethubFactoryImpl } = m.useModule(assethubFactoryImplModule);
  const feeCollectModuleFactory = m.contract(Contracts.FeeCollectModuleFactory, []);
  const nftGatedModuleFactory = m.contract(Contracts.NftAssetGatedModuleFactory, []);

  m.call(assethubManager, "initialize", [[assethubFactoryImpl, feeCollectModuleFactory, nftGatedModuleFactory]]);
  return { assethubManager };
});

export const deployAssetHubModule = buildModule("DeployAssetHub", (m) => {
  const deployer = m.getAccount(0);
  const { assethubManager } = m.useModule(assethubFactoryModule)
  m.call(assethubManager, "deploy", [[deployer, "Test AssetHub", true]])
  return { assethubManager }
})