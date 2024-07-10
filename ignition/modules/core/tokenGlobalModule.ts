import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";
import { ContractFuture } from "@nomicfoundation/ignition-core";

export const TokenGlobalModule = buildModule(Contracts.TokenGlobalModule, m => {
  const impl = m.contract(Contracts.TokenGlobalModule, [], {
    id: Contracts.TokenGlobalModule + "_impl",
  });
  const proxy = m.contract("UpgradeableProxy", [impl, "0x"], {
    id: Contracts.TokenGlobalModule + "_proxy",
  })
  const tokenGlobalModule = m.contractAt(Contracts.TokenGlobalModule, proxy);
  return { tokenGlobalModule };
})

export const TokenGlobalModuleWithInit = (manager: ContractFuture<string>, token: ContractFuture<string>) => {
  return buildModule(Contracts.TokenGlobalModule+"_Init", m => {
    const { tokenGlobalModule } = m.useModule(TokenGlobalModule);
    m.call(tokenGlobalModule, "initialize", [manager, token, m.getAccount(0)]);
    return { tokenGlobalModule };
  })
}