import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeTokenGlobalModule_V6", (m) => {
  const tokenGlobalModule = m.contractAt(Contracts.TokenGlobalModule, "0x3Dc8fB2356547C44acEb60461794aE7b9DA70Adb");
  const tokenGlobalModule_next = m.contract(Contracts.TokenGlobalModule, [], {
    id: "tokenGlobalModule_next"
  });
  const ca = m.call(tokenGlobalModule, "upgradeToAndCall", [tokenGlobalModule_next, "0x"]);
  return {tokenGlobalModule};
})