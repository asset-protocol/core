import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeCuration_V2", (m) => {
  const curation = m.contractAt(Contracts.Curation, "0xBdD18503ae060FB7802705AAC8b7E4a1B63463eD", {
    id: "curationProxy"
  });

  const curationNext = m.contract(Contracts.Curation, [], {
    id: "nextCuration",
  })

  m.call(curation, "upgradeToAndCall", [curationNext, "0x"])
  return {}
});