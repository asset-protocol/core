import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';
import { Contracts } from './core/contracts';
import { ASSETHUB_MANAGER } from './consts';

export default buildModule('UpgradeAssetHub_V2', (m) => {
  const manager = m.contractAt(Contracts.AssetHubManager, ASSETHUB_MANAGER);
  const hubNext = m.contract(Contracts.AssetHub, [], {
    id: 'nextAssetHub',
    libraries: {
      AssetHubLogic: m.library(Contracts.AssetHubLogic),
    },
  });

  m.call(manager, 'upgradeAssetHub', [hubNext]);
  return {};
});
