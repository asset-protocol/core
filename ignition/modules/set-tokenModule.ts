import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("SetGlobalTokenModuleCollectFee_v3", (m) => {
  const TokenGlobalModule = m.contractAt(Contracts.TokenGlobalModule, "0x4125cEC24BE894c3ACeAeAB3a55007f2C19821B9");
  // m.call(TokenGlobalModule, "setToken", ["0xc2ADF187D9B064F68FcD8183195cddDB33E10E8F"]);
  m.call(TokenGlobalModule, "setRecipient", ["0x4845Af017fc4A19B0D053806B7288bB269de05b3"]);
  // m.call(TokenGlobalModule, "setDefaultConfig", [[300000000000, 200000000000, 100000000000]]);
  return { TokenGlobalModule };
})