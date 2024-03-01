import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { assethubFactoryModule } from "./core/assetHubFactory";

export default buildModule("DeployAssetHubFactory", (m) => {
  const { assethubManager } = m.useModule(assethubFactoryModule)
  return { assethubManager };
})