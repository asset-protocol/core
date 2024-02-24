import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("UpgradeAssetHub", (m) => {
  const assethub = m.contractAt("ERC1967Proxy", "0xDD97348935bF46a947C41ef2E9389eFC26EeD363")

  const assethub_Next = m.contract("AssetHub", [], {
    id: "AssetHub_Next",
  })

  m.call(assethub, "upgradeToAndCall", [assethub_Next, "0x"])
  return {}
});