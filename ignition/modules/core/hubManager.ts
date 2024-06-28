import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';
import { IgnitionModuleBuilder } from '@nomicfoundation/ignition-core';
import { Contracts } from './contracts';
import {
  AssetHubImplModule,
  CollectNFTImplModule,
  FeeCollectModule,
  NftAssetGatedModule,
  TokenCollectModule,
} from './modulesImpl';
import { assethubCreatorNFTModule } from './assethubCreatorNft';
import { ZeroAddress } from 'ethers';
import { CurationModule } from './curation';
import { TokenGlobalModuleWithInit } from './tokenGlobalModule';
import TestToken from './TestToken';

export const AssetHubManagerModule = buildModule(Contracts.AssetHubManager, (m) => {
  const impl = m.contract(Contracts.AssetHubManager, [], {
    id: Contracts.AssetHubManager + '_impl',
  });
  const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
  const manager = m.contractAt(Contracts.AssetHubManager, proxy);
  return { manager };
});

export const callLiteAssetHubManagerInit = (m: IgnitionModuleBuilder) => {
  const { manager } = m.useModule(AssetHubManagerModule);
  const { assetHubImpl } = m.useModule(AssetHubImplModule);
  const { collectNFTImpl } = m.useModule(CollectNFTImplModule(manager));
  const { feeCollectModule } = m.useModule(FeeCollectModule(manager));
  const { tokenCollectModule } = m.useModule(TokenCollectModule(manager));
  const { nftAssetGatedModule } = m.useModule(NftAssetGatedModule(manager));
  const { creatorNFT } = m.useModule(assethubCreatorNFTModule);
  const { testToken } = m.useModule(TestToken);
  const { tokenGlobalModule } = m.useModule(TokenGlobalModuleWithInit(manager, testToken));
  const { curation } = m.useModule(CurationModule('Asset Curation', 'AC', manager));
  m.call(manager, 'initialize', [
    [
      assetHubImpl,
      ZeroAddress, // create module
      collectNFTImpl,
      feeCollectModule,
      tokenCollectModule,
      nftAssetGatedModule,
    ],
    creatorNFT,
    tokenGlobalModule,
    curation,
  ]);
  m.call(creatorNFT, 'airdrop', [[m.getAccount(0)]]);
  return {
    manager,
    tokenGlobalModule,
    creatorNFT,
    feeCollectModule,
    tokenCollectModule,
    nftAssetGatedModule,
    curation,
    testToken,
  };
};
