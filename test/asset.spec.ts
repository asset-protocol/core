import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { DeployCtx, deployContracts, user, userAddress } from "./setup.spec";
import { AssetHub } from "../typechain-types";
import { ZeroAddress } from "ethers";

describe("Create Asset", async () => {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHubImpl.connect(user)
    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      subscribeModule: ZeroAddress,
      subscribeModuleInitData: "0x",
    })).to.not.be.reverted
  })

  it("should create asset", async function () {
    expect(await assetHub.balanceOf(userAddress)).to.be.equal(1)
    expect(await assetHub.count(userAddress)).to.be.equal(1)
  })
})