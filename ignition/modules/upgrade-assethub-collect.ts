import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeTokenCollectModule", (m) => {
  const tokenCollectModule = m.contractAt(Contracts.TokenCollectModule, "0x214C6fA6268713ED017302C0CB7011B5e24b86ff", {
    id: "tokenCollectModule"
  });
  const tokenCollectModule_next = m.contract(Contracts.TokenCollectModule, [], {
    id: "tokenCollectModule_next"
  });
  m.call(tokenCollectModule, "upgradeToAndCall", [tokenCollectModule_next, "0x"])
  return {}
});