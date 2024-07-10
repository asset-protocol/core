import { ContractFuture, buildModule } from '@nomicfoundation/ignition-core';
import { Contracts } from './contracts';

export const CurationModule = (
  name: string,
  symbol: string,
  manager: ContractFuture<string>,
  moduleName?: string
) => {
  return buildModule(moduleName ?? Contracts.Curation, (m) => {
    const impl = m.contract(Contracts.Curation, [], {
      id: Contracts.Curation + '_impl',
      libraries: {
        [Contracts.CurationLogic]: m.library(Contracts.CurationLogic)
      }
    });
    const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
    const curation = m.contractAt(Contracts.Curation, proxy);
    m.call(curation, 'initialize', [name, symbol, manager]);
    return { curation };
  });
};
