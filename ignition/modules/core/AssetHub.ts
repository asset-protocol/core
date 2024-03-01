import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";

export const assethubImplModule = buildModule(Contracts.AssetHub + "_impl", (m) => {
  const assethubImpl = m.contract("AssetHub", [], {
    id: Contracts.AssetHub + "_impl",
    libraries:{
      AssetHubLogic: m.contract("AssetHubLogic", [])
    }
  });
  return { assethubImpl };
});

export const assethubModule = buildModule(Contracts.AssetHub, (m) => {
  const { assethubImpl } = m.useModule(assethubImplModule);
  const assethubProxy = m.contract("ERC1967Proxy", [assethubImpl, "0x"], {
    id: Contracts.AssetHub+"_proxy"
  })
  const assethub = m.contractAt(Contracts.AssetHub, assethubProxy)
  return { assethub };
});