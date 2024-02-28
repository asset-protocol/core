import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";

export const assethubFactoryImplModule = buildModule(Contracts.AssetHubFactory + "_impl", (m) => {
  const assethubFactoryImpl = m.contract(Contracts.AssetHubFactory, [], {
    id: Contracts.AssetHubFactory + "_impl"
  });
  return { assethubFactoryImpl };
});

export const assethubFactoryModule = buildModule(Contracts.AssetHubFactory, (m) => {
  const { assethubFactoryImpl } = m.useModule(assethubFactoryImplModule);
  const assethubFactoryProxy = m.contract("ERC1967Proxy", [assethubFactoryImpl, "0x"], {
    id: Contracts.AssetHubFactory + "_proxy"
  })
  const assethubFactory = m.contractAt(Contracts.AssetHubFactory, assethubFactoryProxy)
  return { assethubFactory };
});