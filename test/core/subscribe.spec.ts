import { DeployCtx, deployContracts, deployer, user, userAddress } from "../setup.spec";
import { AssetHub, EmptySubscribeModule__factory } from "../../typechain-types";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ZeroAddress } from "ethers";
import { ERRORS } from "../helpers/errors";
import { ZERO_DATA } from "../contants";

describe("Subcribe to Asset", async function () {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  const firstAssetId = 1
  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHubImpl.connect(user)
    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      subscribeModule: ZeroAddress,
      subscribeModuleInitData: ZERO_DATA,
    })).to.not.be.reverted
  })

  it("should subscribe to asset", async function () {
    await expect(await assetHub.subscribe(firstAssetId, ZERO_DATA)).to.not.be.reverted
    expect(await assetHub.totalSubscribers(firstAssetId)).to.be.equal(1)
    expect(await assetHub.subscribedCount(firstAssetId, user)).to.be.equal(1)
    const nft = await assetHub.subscribeNFTContract(firstAssetId)
    expect(nft).to.not.be.equal(ZeroAddress)
  })

  it("should revert when subscribe to asset that does not exist", async function () {
    await expect(assetHub.subscribe(999, ZERO_DATA))
      .to.be.revertedWithCustomError(assetHub, ERRORS.AssetDoesNotExist)
  })

  // test set subscribe module whitelist
  it("should revert when set subscribe module whitelist by non admin", async function () {
    const sm = await new EmptySubscribeModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()
    const assetHub = cts.assetHubImpl.connect(user)
    await expect(assetHub.subscribeModuleWhitelist(smAdrr, true))
      .to.be.revertedWithCustomError(assetHub, ERRORS.OwnableUnauthorizedAccount)
      .withArgs(userAddress)
  })

  it("should set subscribe module whitelist by admin", async function () {
    const sm = await new EmptySubscribeModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()
    const adminAssertHub = cts.assetHubImpl.connect(deployer)
    await expect(adminAssertHub.subscribeModuleWhitelist(smAdrr, true)).to.not.be.reverted
  })

  it("isSubscribeModuleWhitelisted should return true after set subscribe module whitelist", async function () {
    const adminAssertHub = cts.assetHubImpl.connect(deployer)
    const sm = await new EmptySubscribeModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()

    expect(await adminAssertHub.isSubscribeModuleWhitelisted(smAdrr)).to.be.false
    await expect(adminAssertHub.subscribeModuleWhitelist(smAdrr, true))
      .to.not.be.reverted
    expect(await adminAssertHub.isSubscribeModuleWhitelisted(smAdrr)).to.be.true
  })

  it("should revert when create asset with a subscribe module that is not whitelisted", async function () {
    const sm = await new EmptySubscribeModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()
    const assetHub = cts.assetHubImpl.connect(user)
    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      subscribeModule: smAdrr,
      subscribeModuleInitData: ZERO_DATA,
    })).to.be.revertedWithCustomError(assetHub, ERRORS.SubscribeModuleNotWhitelisted)
  })

  it("should created asset with a subscribe module that is whitelisted", async function () {
    const sm = await new EmptySubscribeModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()

    const adminAssertHub = cts.assetHubImpl.connect(deployer)
    await expect(adminAssertHub.subscribeModuleWhitelist(smAdrr, true)).to.not.be.reverted

    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      subscribeModule: smAdrr,
      subscribeModuleInitData: ZERO_DATA,
    })).to.not.be.reverted
  })
})