

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import AssethubCoreModule from "./deploy-newhub"
import { assethubModule } from "./core/assetHub";
import { Contracts } from "./core/contracts";
import { ZeroAddress } from "ethers";

// export default buildModule("DeployAssetCore", (m) => {
//   const deployer = m.getAccount(0);
//   const { assethub } = m.useModule(assethubModule)
//   const collectNFT = m.contract(Contracts.CollectNFT, [assethub]);
//   m.call(assethub, "initialize", ["AssetHub", "AH", deployer, collectNFT, ZeroAddress])
//   return { assethub }
// });