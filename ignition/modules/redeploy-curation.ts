import { buildModule } from '@nomicfoundation/hardhat-ignition/modules';
import { Contracts } from './core/contracts';
import { CurationModule } from './core/curation';

export default buildModule('RedeployCuration_V2', (m) => {
  const manager = m.contractAt(
    Contracts.AssetHubManager,
    '0x5910a60566153a1c2199fa1C54f7bEB998B5B163'
  );
  const curationModule = CurationModule('Curation', 'AC', manager, Contracts.Curation + '_V2');
  const { curation } = m.useModule(curationModule);
  m.call(manager, 'setCuration', [curation.address]);
  return {};
});
