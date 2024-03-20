import { expect } from "chai";
import { deployer, hubManager } from "../setup.spec";
import { ZeroAddress } from "ethers";

const HUB_NAME = "TEST_HUB"

describe("AssetHubFactory", async function () {
  it("should deploy a new assethub", async function () {
    const args = {
      admin: await deployer.getAddress(),
      name: HUB_NAME,
      collectNft: true,
      assetCreateModule: ZeroAddress,
    }
    await expect(hubManager.deploy(args)).to.not.be.reverted;
  });

  it("should not deploy a existed name hub", async function () {
    await expect(hubManager.deploy({
      admin: await deployer.getAddress(),
      name: HUB_NAME,
      collectNft: true,
      assetCreateModule: ZeroAddress,
    })).to.be.revertedWithCustomError(hubManager, "NameHubExisted")
      .withArgs(HUB_NAME);
  })

  it("should deploy a new name hub", async function () {
    await expect(hubManager.deploy({
      admin: await deployer.getAddress(),
      name: HUB_NAME + "_V2",
      collectNft: true,
      assetCreateModule: ZeroAddress,
    })).to.not.be.reverted;
  })
});