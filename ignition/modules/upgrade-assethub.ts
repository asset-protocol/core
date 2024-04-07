import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeAssetHub_V3", (m) => {

  const assetHub = m.contractAt(Contracts.AssetHub, "0xE576fCDAD5B058C7Fab2cd73464dFa83D9a2d6d9",{
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