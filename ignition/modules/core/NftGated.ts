
import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";
import { assethubModule } from "./AssetHub";

export const NftAssetGatedModuleImpl = buildModule(Contracts.NftAssetGatedModule + "Impl", (m) => {
  const assethubImpl = m.contract(Contracts.NftAssetGatedModule, []);
  return { assethubImpl };
});

export default buildModule(Contracts.NftAssetGatedModule, (m) => {
  const nftGatedModuleImpl = m.useModule(NftAssetGatedModuleImpl).assethubImpl;
  const nftGatedModuleProxy = m.contract("ERC1967Proxy", [nftGatedModuleImpl, "0x"])

  const nftGatedModule = m.contractAt(Contracts.NftAssetGatedModule, nftGatedModuleProxy);
  const { assethub } = m.useModule(assethubModule)
  m.call(nftGatedModule, "initialize", [assethub, m.getAccount(0)]);
  return { nftGatedModule };
});