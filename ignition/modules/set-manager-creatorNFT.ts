import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";
import { ASSETHUB_MANAGER } from "./consts";
import { assethubCreatorNFTModule } from "./core/assethubCreatorNft";

export default buildModule("SetManagerCreatorNFT", (m) => {
  const manager = m.contractAt(Contracts.AssetHubManager, ASSETHUB_MANAGER);
  const { creatorNFT } = m.useModule(assethubCreatorNFTModule);
  m.call(manager, "setHubCreatorNFT", [creatorNFT]);
  return { manager };
})