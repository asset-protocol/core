import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeAssetHub_V3", (m) => {

  const assetHub = m.contractAt(Contracts.AssetHub, "0xC2876F1d401aDe7041774AE81b3b272476e43eC0",{
    id: "assetHubProxy"
  });

  const hubNext = m.contract(Contracts.AssetHub, [], {
    id:"nextAssetHub",
    libraries: {
      "AssetHubLogic": m.library(Contracts.AssetHubLogic)
    }
  })

  m.call(assetHub, "upgradeToAndCall", [hubNext, "0x"])
  return {}
});