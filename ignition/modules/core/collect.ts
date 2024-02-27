import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";
import { assethubModule } from "./assetHub";

export const FeeCollectModule = buildModule(Contracts.FeeCollectModule, (m) => {
  const { assethub } = m.useModule(assethubModule);
  const feeCollect = m.contract(Contracts.FeeCollectModule, [assethub]);
  return { feeCollect };
})

export const RevertCollectModule = buildModule(Contracts.RevertCollectModule, (m) => {
  const { assethub } = m.useModule(assethubModule);
  const revertCollect = m.contract(Contracts.RevertCollectModule, [assethub]);
  return { revertCollect };
})