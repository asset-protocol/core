import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeTokenGlobalModule_V5", (m) => {
  const tokenGlobalModule = m.contractAt(Contracts.TokenGlobalModule, "0xc9b375297914BF0892DCDcF04D56134375CeE245");
  const tokenGlobalModule_next = m.contract(Contracts.TokenGlobalModule, [], {
    id: "tokenGlobalModule_next"
  });
  const ca = m.call(tokenGlobalModule, "upgradeToAndCall", [tokenGlobalModule_next, "0x"]);
  return {tokenGlobalModule};
})