import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import TestTokenModule from './core/TestToken'

export default buildModule("DeployTestContract", (m) => {
  const { testToken } = m.useModule(TestTokenModule);
  m.call(testToken, "mint", ["0x4845Af017fc4A19B0D053806B7288bB269de05b3", 100000])
  return { testToken }
});