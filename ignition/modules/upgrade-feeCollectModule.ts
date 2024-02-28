import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";
import { assethubModule } from "./core/assetHub";
import { FeeCollectModule } from "./core/collect";

export default buildModule("UpgradeFeeCollectModule", (m) => {
  const { assethub } = m.useModule(assethubModule)
  const feeCollectModuleNext = m.contract(Contracts.FeeCollectModule, [assethub], {
    id: Contracts.FeeCollectModule + "_Next"
  })
  const { feeCollect } = m.useModule(FeeCollectModule)
  m.call(feeCollect, "upgradeToAndCall", [feeCollectModuleNext, "0x"])
  return {}
});