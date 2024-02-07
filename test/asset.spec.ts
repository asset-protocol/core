import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { DeployCtx, accounts, deployContracts, deployer, user, userAddress } from "./setup.spec";
import { AssetHub } from "../typechain-types";
import { ZeroAddress } from "ethers";
import { ERRORS } from "./helpers/errors";
import { ZERO_DATA } from "./contants";

describe("Create Asset", async () => {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
  })

  it("should create asset", async function () {
    assetHub = cts.assetHubImpl.connect(user)
    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      subscribeModule: ZeroAddress,
      subscribeModuleInitData: ZERO_DATA,
    })).to.not.be.reverted
    expect(await assetHub.balanceOf(userAddress)).to.be.equal(1)
    expect(await assetHub.count(userAddress)).to.be.equal(1)
    expect(await assetHub.tokenURI(1)).to.be.equal("https://www.google.com")
  })


  it("should not allow create asset with invalid publisher", async function () {
    const thirdUser = accounts[2]
    await expect(assetHub.create({
      publisher: thirdUser,
      contentURI: "https://www.google.com",
      subscribeModule: ZeroAddress,
      subscribeModuleInitData: "0x",
    })).to.be.revertedWithCustomError(assetHub, ERRORS.OwnableInvalidOwner)
      .withArgs(await user.getAddress())
  })

  it("should create asset of the third publisher with owner", async function () {
    const thirdUser = accounts[2]
    const ownerHub = cts.assetHubImpl.connect(deployer)
    await expect(ownerHub.create({
      publisher: thirdUser,
      contentURI: "https://www.google.com",
      subscribeModule: ZeroAddress,
      subscribeModuleInitData: "0x",
    })).to.be.not.reverted
  })
})