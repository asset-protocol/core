import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";

export default buildModule("DeployTokenGlobalModule", m => {
  const impl = m.contract(Contracts.TokenGlobalModule, [], {
    id: Contracts.TokenGlobalModule + "_impl",
  });
  const proxy = m.contract("UpgradeableProxy", [impl, "0x"], {
    id: Contracts.TokenGlobalModule + "_proxy",
  })
  const tokenGlobalModule = m.contractAt(Contracts.TokenGlobalModule, proxy);
  return { tokenGlobalModule };
})