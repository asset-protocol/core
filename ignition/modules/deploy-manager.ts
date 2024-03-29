import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { assethubManagerInitModule } from "./core/assetHubFactory";

export default buildModule("DeployAssetHubManager", (m) => {
  const { assethubManager } = m.useModule(assethubManagerInitModule)
  return { assethubManager };
})