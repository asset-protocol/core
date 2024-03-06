import { expect } from "chai";
import { deployer, hubManager } from "../setup.spec";

describe("AssetHubFactory", async function () {
  it("should deploy a new assethub", async function () {
    await expect(hubManager.deploy({
      admin: await deployer.getAddress(),
      name: "Test AssetHub",
      collectNft: true
    })).to.not.be.reverted;
  });
});