import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { callLiteAssetHubManagerInit } from "./core/liteManager";

export default buildModule("DeployLiteAssetHubManager", (m) => {
  return callLiteAssetHubManagerInit(m);
})