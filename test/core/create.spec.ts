import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { AssetHub, EmptyCreateModule__factory } from "../../typechain-types"
import { DeployCtx, deployContracts, deployer, user, userAddress } from "../setup.spec"
import { expect } from "chai"
import { ZeroAddress } from "ethers"
import { ZERO_DATA } from "../contants"
import { ERRORS } from "../helpers/errors"

describe("create to Asset with createModule", async function () {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  const firstAssetId = 1
  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHubImpl.connect(user)

  })

  it("should create asset with empty createModule", async function () {
    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      subscribeModule: ZeroAddress,
      subscribeModuleInitData: ZERO_DATA,
      createModule: ZeroAddress,
      createModuleInitData: ZERO_DATA,
    })).to.not.be.reverted
  })

  // test set subscribe module whitelist
  it("should revert when set create module whitelist by non admin", async function () {
    const sm = await new EmptyCreateModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()
    const assetHub = cts.assetHubImpl.connect(user)
    await expect(assetHub.createModuleWhitelist(smAdrr, true))
      .to.be.revertedWithCustomError(assetHub, ERRORS.OwnableUnauthorizedAccount)
      .withArgs(userAddress)
  })

  it("should set create module whitelist by admin", async function () {
    const sm = await new EmptyCreateModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()
    const adminAssertHub = cts.assetHubImpl.connect(deployer)
    await expect(adminAssertHub.subscribeModuleWhitelist(smAdrr, true)).to.not.be.reverted
  })

  it("isCreateModuleWhitelisted should return true after set create module whitelist", async function () {
    const adminAssertHub = cts.assetHubImpl.connect(deployer)
    const sm = await new EmptyCreateModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()

    expect(await adminAssertHub.isCreateModuleWhitelisted(smAdrr)).to.be.false
    await expect(adminAssertHub.createModuleWhitelist(smAdrr, true))
      .to.not.be.reverted
    expect(await adminAssertHub.isCreateModuleWhitelisted(smAdrr)).to.be.true
  })

  it("should revert when create asset with a create module that is not whitelisted", async function () {
    const sm = await new EmptyCreateModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()
    const assetHub = cts.assetHubImpl.connect(user)
    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      subscribeModule: ZeroAddress,
      subscribeModuleInitData: ZERO_DATA,
      createModule: smAdrr,
      createModuleInitData: ZERO_DATA,
    })).to.be.revertedWithCustomError(assetHub, ERRORS.CreateModuleNotWhitelisted)
  })

  it("should created asset with a create module that is whitelisted", async function () {
    const sm = await new EmptyCreateModule__factory(user).deploy()
    const smAdrr = await sm.getAddress()

    const adminAssertHub = cts.assetHubImpl.connect(deployer)
    await expect(adminAssertHub.createModuleWhitelist(smAdrr, true)).to.not.be.reverted

    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      subscribeModule: ZeroAddress,
      subscribeModuleInitData: ZERO_DATA,
      createModule: smAdrr,
      createModuleInitData: ZERO_DATA,
    })).to.not.be.reverted
  })

})