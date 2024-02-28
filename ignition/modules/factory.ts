import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { assethubFactoryModule } from "./core/assetHubFactory";
import { FeeCollectModule } from "./core/collect";
export default buildModule("DeployAssetHubFactory", (m) => {
  const {} = m.useModule(FeeCollectModule)


  const { assethubFactory } = m.useModule(assethubFactoryModule)
})