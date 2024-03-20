import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeAssetHub", (m) => {

  const assetHub = m.contractAt(Contracts.AssetHub, "0xC20f603Bc1D0B558CA3a0880EEa3B733FC15b85d",{
    id: "assetHubProxy"
  });

  const hubNext = m.contract(Contracts.AssetHub, [], {
    id:"nextAssetHub",
    libraries: {
      "contracts/base/AssetHubLogic.sol:AssetHubLogic": m.library(Contracts.AssetHubLogic)
    }
  })

  m.call(assetHub, "upgradeToAndCall", [hubNext, "0x"])
  return {}
});