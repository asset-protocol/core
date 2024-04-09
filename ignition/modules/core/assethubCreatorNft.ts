import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";

export const assethubCreatorNFTModule = buildModule(Contracts.AssetHubCreatorNFT, (m) => {
  const impl = m.contract(Contracts.AssetHubCreatorNFT, [], {
    id: Contracts.AssetHubCreatorNFT + "_impl",
  });
  const creatorNFTProxy = m.contract("UpgradeableProxy", [impl, "0x"], {
    id: Contracts.AssetHubCreatorNFT + "_proxy",
  })
  const creatorNFT = m.contractAt(Contracts.AssetHubCreatorNFT, creatorNFTProxy);
  m.call(creatorNFT, "initialize", ["Asset Hub Creator", "AH_CREATOR"]);
  return { creatorNFT, creatorNFTProxy };
});