import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { assethubModule } from "./core/assetHub"
import TestTokenModule from "./core/TestToken"

export default buildModule("UpgradeFeeAssetModule", (m) => {
  const deployer = m.getAccount(0);

  const { assethub } = m.useModule(assethubModule)
  const { testToken } = m.useModule(TestTokenModule)

  const assetModule = m.contract("FeeCreateAssetModule", [assethub, testToken, deployer])
  m.call(assethub, "setAssetModule", [assetModule])
  return {}
});