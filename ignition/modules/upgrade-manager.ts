import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { assethubManagerModule } from "./core/assetHubFactory";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeManager", (m) => {
  const { assethubManagerProxy } = m.useModule(assethubManagerModule)

  const managerNext = m.contract(Contracts.AssetHubManager, [])

  m.call(assethubManagerProxy, "upgradeToAndCall", [managerNext, "0x"])
  return {}
});