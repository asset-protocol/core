import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";
import { assethubManagerModule } from "./core/assetHubFactory";
import { ZeroAddress } from "ethers";

export default buildModule("UpgradeTokenCollectModule", (m) => {
  const { assethubManager } = m.useModule(assethubManagerModule);
  const tokenCollectModuleFactory_next = m.contract(Contracts.TokenCollectModuleFactory, []);
  m.call(assethubManager, "setFactories", [[ZeroAddress, tokenCollectModuleFactory_next, ZeroAddress, ZeroAddress, ZeroAddress]]);
  return {};
})