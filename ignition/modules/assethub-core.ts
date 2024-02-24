import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import "@openzeppelin/hardhat-upgrades"
import { assethubModule } from "./core/AssetHub"
import { ZeroAddress } from "ethers";
import { Contracts } from "./core/contracts";

export default buildModule("AssetHub_Core", (m) => {
  const deployer = m.getAccount(0);
  const { assethub } = m.useModule(assethubModule)
  const collectNFT = m.contract(Contracts.CollectNFT, [assethub]);
  m.call(assethub, "initialize", ["AssetHub", "AH", deployer, collectNFT, ZeroAddress])
  return { assethub }
});