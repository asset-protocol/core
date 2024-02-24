import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("TestToken", (m) => {
  const testToken = m.contract("TestToken", ["TestToken",""]);
  return { testToken };
});