import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";
import { assethubModule } from "./assetHub";

export const FeeCollectModule = buildModule(Contracts.FeeCollectModule, (m) => {
  const { assethub } = m.useModule(assethubModule);
  const feeCollectImpl = m.contract(Contracts.FeeCollectModule, [], {
    id: Contracts.FeeCollectModule + "_impl"
  });
  const feeCollectModuleProxy = m.contract("ERC1967Proxy", [feeCollectImpl, "0x"], {
    id: Contracts.FeeCollectModule + "_proxy"
  })
  const feeCollect = m.contractAt(Contracts.FeeCollectModule, feeCollectModuleProxy, {
    id: Contracts.FeeCollectModule
  });
  m.call(feeCollect, "initialize", [assethub, m.getAccount(0)]);
  return { feeCollect, feeCollectImpl };
})

export const RevertCollectModule = buildModule(Contracts.RevertCollectModule, (m) => {
  const { assethub } = m.useModule(assethubModule);
  const revertCollect = m.contract(Contracts.RevertCollectModule, [assethub]);
  return { revertCollect };
})