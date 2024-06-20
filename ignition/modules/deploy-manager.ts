import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { callLiteAssetHubManagerInit } from "./core/hubManager";

export default buildModule("DeployLiteAssetHubManager", (m) => {
  return callLiteAssetHubManagerInit(m);
})