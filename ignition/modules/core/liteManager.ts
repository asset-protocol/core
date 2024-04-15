import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { IgnitionModuleBuilder } from '@nomicfoundation/ignition-core';
import { Contracts } from "./contracts";
import { AssetHubImplModule, OneCollectNFTImplModule, OneFeeCollectModule, OneNftAssetGatedModule, OneTokenCollectModule } from "./modulesImpl";
import { assethubCreatorNFTModule } from "./assethubCreatorNft";
import tokenGlobalModuleModule from "./tokenGlobalModule";
import { ZeroAddress } from "ethers";

export const LiteAssetHubManagerModule = buildModule(Contracts.LiteAssetHubManager, (m) => {
  const impl = m.contract(Contracts.LiteAssetHubManager, [], {
    id: Contracts.LiteAssetHubManager + "_impl"
  });
  const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
  const liteManager = m.contractAt(Contracts.LiteAssetHubManager, proxy);
  return { liteManager };
});

export const callLiteAssetHubManagerInit = (m: IgnitionModuleBuilder) => {
  const { liteManager } = m.useModule(LiteAssetHubManagerModule);
  const { assetHubImpl } = m.useModule(AssetHubImplModule);
  const { oneCollectNFTImpl } = m.useModule(OneCollectNFTImplModule(liteManager));
  const { oneFeeCollectModule } = m.useModule(OneFeeCollectModule(liteManager));
  const { oneTokenCollectModule } = m.useModule(OneTokenCollectModule(liteManager));
  const { oneNftAssetGatedModule } = m.useModule(OneNftAssetGatedModule(liteManager));
  const { creatorNFT } = m.useModule(assethubCreatorNFTModule);
  const { tokenGlobalModule } = m.useModule(tokenGlobalModuleModule);
  m.call(liteManager, "initialize", [[
    assetHubImpl,
    ZeroAddress, // create module
    oneCollectNFTImpl,
    oneFeeCollectModule,
    oneTokenCollectModule,
    oneNftAssetGatedModule
  ], creatorNFT, tokenGlobalModule]);
  m.call(creatorNFT, "airdrop", [[m.getAccount(0)]]);
  return {
    liteManager,
    tokenGlobalModule,
    creatorNFT,
    oneFeeCollectModule,
    oneTokenCollectModule,
    oneNftAssetGatedModule
  };
}