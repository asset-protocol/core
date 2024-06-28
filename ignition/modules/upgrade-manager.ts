import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';
import { Contracts } from './core/contracts';
import { ASSETHUB_MANAGER } from './consts';

export default buildModule('UpgradeManager_V2', (m) => {
  const assethubManager = m.contractAt(Contracts.AssetHubManager, ASSETHUB_MANAGER);

  const managerNext = m.contract(Contracts.AssetHubManager, [], {
    id: 'AssetHubManager_next',
  });

  m.call(assethubManager, 'upgradeToAndCall', [managerNext, '0x']);
  return {};
});
