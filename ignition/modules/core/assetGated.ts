
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";
import { assethubModule } from "./assetHub";

export const NftAssetGatedModuleImpl = buildModule(Contracts.NftAssetGatedModule + "_impl", (m) => {
  const assethubImpl = m.contract(Contracts.NftAssetGatedModule, []);
  return { assethubImpl };
});

export const nftAssetGatedModule = buildModule(Contracts.NftAssetGatedModule, (m) => {
  const nftGatedModuleImpl = m.useModule(NftAssetGatedModuleImpl).assethubImpl;
  const nftGatedModuleProxy = m.contract("ERC1967Proxy", [nftGatedModuleImpl, "0x"], {
    id: Contracts.NftAssetGatedModule + "_proxy"
  })

  const nftGatedModule = m.contractAt(Contracts.NftAssetGatedModule, nftGatedModuleProxy);
  const { assethub } = m.useModule(assethubModule)
  m.call(nftGatedModule, "initialize", [assethub, m.getAccount(0)]);
  return { nftGatedModule };
});


export const upgradeNftGatedModule = buildModule("UpgradeNftGatedModule", (m) => {
  const nftGatedModule = m.useModule(nftAssetGatedModule).nftGatedModule;
  const nftGatedModule_Next = m.contract(Contracts.NftAssetGatedModule, [], {
    id: "NftGatedModule_Next",
  })
  m.call(nftGatedModule, "upgradeToAndCall", [nftGatedModule_Next, "0x"])
  return {}
});