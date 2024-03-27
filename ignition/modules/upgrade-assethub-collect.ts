import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeTokenCollectModule", (m) => {
  const tokenCollectModule = m.contractAt(Contracts.TokenCollectModule, "0x7E08f2E743d0Bd9B19A588f0C7B5EE32d24F51d0", {
    id: "tokenCollectModule"
  });
  const tokenCollectModule_next = m.contract(Contracts.TokenCollectModule, [], {
    id: "tokenCollectModule_next"
  });
  m.call(tokenCollectModule, "upgradeToAndCall", [tokenCollectModule_next, "0x"])
  return {}
});