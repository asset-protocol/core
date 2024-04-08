import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";
import { ZeroAddress } from "ethers";
import { ASSETHUB_MANAGER } from "./consts";

export default buildModule("UpgradeManager_Hub_V1", (m) => {
  const assethubManager = m.contractAt(Contracts.AssetHubManager, ASSETHUB_MANAGER)
  const assethubFactoryNext = m.contract(Contracts.AssetHubFactory, [], {
    id: Contracts.AssetHubFactory,
    libraries: {
      "AssetHubLogic": m.library(Contracts.AssetHubLogic)
    }
  });

  m.call(assethubManager, "setFactories", [[
    assethubFactoryNext,
    ZeroAddress,
    ZeroAddress,
    ZeroAddress,
    ZeroAddress,
    ZeroAddress
  ]])
  return { assethubFactoryNext }
});