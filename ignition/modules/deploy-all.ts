import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssethubCoreModule from "./deploy-newhub"
import TestTokenModule from "./core/TestToken"
import { nftAssetGatedModule } from "./core/assetGated"
import { FeeCollectModule } from "./core/collect";
import { feeCreateModule } from "./core/createModule";

// export default buildModule("DeployAll", (m) => {
//   const { assethub } = m.useModule(AssethubCoreModule)
//   const { testToken } = m.useModule(TestTokenModule)
//   const { nftGatedModule } = m.useModule(nftAssetGatedModule)
//   const { feeCollect } = m.useModule(FeeCollectModule)
//   const { feeCollectModule } = m.useModule(feeCreateModule)
//   return { assethub, nftGatedModule, testToken, feeCollect, feeCollectModule }
// });