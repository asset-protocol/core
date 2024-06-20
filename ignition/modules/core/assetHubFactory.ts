import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';
import { Contracts } from './contracts';
import { ZeroAddress } from 'ethers';
import { AssetHubManagerModule } from './hubManager';

export const assethubFactoryModule = buildModule(Contracts.AssetHubFactory, (m) => {
  const assethubFactory = m.contract(Contracts.AssetHubFactory, [], {
    id: Contracts.AssetHubFactory,
    libraries: {
      AssetHubLogic: m.library(Contracts.AssetHubLogic),
    },
  });
  return { assethubFactory };
});

export const assethubManagerModule = buildModule(Contracts.AssetHubManager, (m) => {
  const assetHubManagerImpl = m.contract(Contracts.AssetHubManager, [], {
    id: Contracts.AssetHubManager + '_impl',
  });
  const assethubManagerProxy = m.contract('UpgradeableProxy', [assetHubManagerImpl, '0x'], {
    id: Contracts.AssetHubManager + '_proxy',
  });
  const assethubManager = m.contractAt(Contracts.AssetHubManager, assethubManagerProxy);
  return { assethubManager, assethubManagerProxy };
});

export const factoriesModule = buildModule(Contracts.AssetHubManager + 'Facotries', (m) => {
  const { assethubFactory } = m.useModule(assethubFactoryModule);
  const tokenCollectModuleFactory = m.contract(Contracts.TokenCollectModuleFactory, []);
  const nftGatedModuleFactory = m.contract(Contracts.NftAssetGatedModuleFactory, []);
  const tokenAssetCreateModuleFactory = m.contract(Contracts.TokenAssetCreateModuleFactory, []);
  const feeCollectModuleFactory = m.contract(Contracts.FeeCollectModuleFactory, []);
  const collectNFTFactory = m.contract(Contracts.CollectNFTFactory, []);
  return {
    assethubFactory,
    tokenCollectModuleFactory,
    nftGatedModuleFactory,
    tokenAssetCreateModuleFactory,
    collectNFTFactory,
    feeCollectModuleFactory,
  };
});

export const deployAssetHubModule = (hubName: string) =>
  buildModule('DeployAssetHub', (m) => {
    const deployer = m.getAccount(0);
    const { liteManager } = m.useModule(AssetHubManagerModule);
    m.call(liteManager, 'deploy', [[deployer, hubName, ZeroAddress, '']]);
    return { liteManager };
  });
