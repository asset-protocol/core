import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./core/contracts";

export default buildModule("UpgradeCuration_V8", (m) => {
  const curation = m.contractAt(Contracts.Curation, "0x8e9172e7D9f08E601168C79c0A43930c4304c483", {
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