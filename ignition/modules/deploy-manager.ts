import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { callAssetHubManagerInit } from "./core/hubManager";

export default buildModule("DeployAssetHubManager", (m) => {
  return callAssetHubManagerInit(m);
})