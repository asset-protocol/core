import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { TokenGlobalModule } from "./core/tokenGlobalModule";

const SetGlobalTokenModuleAssetCollectFee = buildModule("SetGlobalTokenModuleCollectFee_v3", (m) => {
  const { tokenGlobalModule } = m.useModule(TokenGlobalModule);
  // m.call(TokenGlobalModule, "setToken", ["0xc2ADF187D9B064F68FcD8183195cddDB33E10E8F"]);
  // m.call(tokenGlobalModule, "setRecipient", ["0x4845Af017fc4A19B0D053806B7288bB269de05b3"]);
  m.call(tokenGlobalModule, "setAssetDefaultConfig", [[300000000000, 200000000000, 100000000000]]);
  return { tokenGlobalModule };
})

export default SetGlobalTokenModuleAssetCollectFee;