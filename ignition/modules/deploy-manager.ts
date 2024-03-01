import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { assethubManagerModule } from "./core/assetHubFactory";

export default buildModule("DeployAssetHubManager", (m) => {
  const { assethubManager } = m.useModule(assethubManagerModule)
  return { assethubManager };
})