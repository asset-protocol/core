import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeCuration_V2", (m) => {
  const curation = m.contractAt(Contracts.Curation, "0xdBD85f666eE558eEa2BA133993DA91D4666a9879", {
    id: "curationProxy",
  });

  const curationNext = m.contract(Contracts.Curation, [], {
    id: "nextCuration",
    libraries: {
      "CurationLogic": m.library(Contracts.CurationLogic)
    }
  })

  m.call(curation, "upgradeToAndCall", [curationNext, "0x"])
  return {}
});