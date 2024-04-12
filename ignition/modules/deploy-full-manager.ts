import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { IgnitionModuleBuilder } from "@nomicfoundation/ignition-core"
import { factoriesModule, assethubManagerModule } from "./core/assetHubFactory";
import tokenGlobalModuleModule from "./core/tokenGlobalModule";
import { assethubCreatorNFTModule } from "./core/assethubCreatorNft";

const initGlobalModule = (m: IgnitionModuleBuilder) => {
  const { tokenGlobalModule } = m.useModule(tokenGlobalModuleModule);
  const { assethubManager } = m.useModule(assethubManagerModule)
  m.call(tokenGlobalModule, "initialize", [
    assethubManager,
    "0xc2ADF187D9B064F68FcD8183195cddDB33E10E8F",
    m.getAccount(0),
    [300000000000, 200000000000, 100000000000],
  ]);
}

const initManager = (m: IgnitionModuleBuilder) => {
  const {
    assethubFactory,
    tokenCollectModuleFactory,
    nftGatedModuleFactory,
    tokenAssetCreateModuleFactory,
    feeCollectModuleFactory,
    collectNFTFactory } = m.useModule(factoriesModule);
  const { assethubManager } = m.useModule(assethubManagerModule);
  const { tokenGlobalModule } = m.useModule(tokenGlobalModuleModule);
  const { creatorNFT } = m.useModule(assethubCreatorNFTModule);
  m.call(assethubManager, "initialize", [
    [
      assethubFactory,
      tokenCollectModuleFactory,
      nftGatedModuleFactory,
      tokenAssetCreateModuleFactory,
      collectNFTFactory,
      feeCollectModuleFactory
    ], creatorNFT, tokenGlobalModule]);
}

export default buildModule("DeployFullTestHub", (m) => {
  initManager(m);
  initGlobalModule(m);
  return {}
});