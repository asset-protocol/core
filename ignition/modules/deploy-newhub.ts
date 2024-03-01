import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import "@openzeppelin/hardhat-upgrades"
import { deployAssetHubModule } from "./core/assetHubFactory";

export default buildModule("DeployNewAssetHub", (m) => {
  return m.useModule(deployAssetHubModule);
});