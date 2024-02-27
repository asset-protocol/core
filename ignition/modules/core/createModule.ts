import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";
import { assethubModule } from "./assetHub";
import testTkenModule from "./TestToken";

export const feeCreateModule = buildModule(Contracts.FeeCreateAssetModule, (m) => {
  const { assethub } = m.useModule(assethubModule);
  const { testToken } = m.useModule(testTkenModule)
  const feeCollectModule = m.contract(
    Contracts.FeeCreateAssetModule,
    [assethub, testToken, m.getAccount(0)]
  );
  m.call(assethub, "setCreateAssetModule", [feeCollectModule])
  return { feeCollectModule };
});