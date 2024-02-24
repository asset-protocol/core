import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export const assethubImplModule = buildModule("AssetHub", (m) => {
  const assethubImpl = m.contract("AssetHub", []);
  return { assethubImpl };
});

export const assethubModule = buildModule("AssetHubProxy", (m) => {
  const { assethubImpl } = m.useModule(assethubImplModule);
  const assethubProxy = m.contract("ERC1967Proxy", [assethubImpl, "0x"])
  const assethub = m.contractAt("AssetHub", assethubProxy)
  return { assethub };
});