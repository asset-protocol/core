import { DeployCtx, assetHubLogic, assethubLibs, deployContracts, deployer, user, userAddress } from "../../setup.spec";
import { AssetHub, EmptyCollectModule__factory, Events__factory } from "../../../typechain-types";
import { loadFixture, time } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ZeroAddress } from "ethers";
import { ERRORS } from "../../helpers/errors";
import { ZERO_DATA } from "../../contants";
import { ethers } from "hardhat";

describe("Subcribe to Asset with free module", async function () {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  let firstAssetId = BigInt(-1)
  let assetCollectNFT = ""
  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHub.connect(user)
    const createData = {
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      collectModule: ZeroAddress,
      collectModuleInitData: ZERO_DATA,
      assetCreateModuleData: ZERO_DATA,
      gatedModule: ZeroAddress,
      gatedModuleInitData: ZERO_DATA,
    }
    firstAssetId = await assetHub.create.staticCall(createData)
    await expect(assetHub.create(createData)).to.not.be.reverted
    assetCollectNFT = await assetHub.assetCollectNFT(firstAssetId)
  })

  it("should collect to asset", async function () {
    const bt = await time.latest()
    const collectTokenId = await assetHub.collect.staticCall(firstAssetId, ZERO_DATA)
    const libHub = await ethers.getContractAt("AssetHubLogic", assetHub)
    await expect(await assetHub.collect(firstAssetId, ZERO_DATA))
      .to.be.emit(libHub, "Collected")
      .withArgs(
        firstAssetId,
        userAddress,
        userAddress,
        assetCollectNFT,
        collectTokenId,
        ZeroAddress,
        ZERO_DATA,
        bt + 1
      )
    expect(await assetHub.assetCollectCount(firstAssetId)).to.be.equal(1)
    expect(await assetHub.userCollectCount(firstAssetId, user)).to.be.equal(1)
    const nft = await assetHub.assetCollectNFT(firstAssetId)
    expect(nft).to.not.be.equal(ZeroAddress)
  })

  it("should revert when collect to asset that does not exist", async function () {
    await expect(assetHub.collect(999, ZERO_DATA))
      .to.be.revertedWithCustomError(assetHub, ERRORS.AssetDoesNotExist)
  })

  // test set collect module whitelist
  it("should revert when set collect module whitelist by non admin", async function () {
    const assetHub = cts.assetHub.connect(user)
    const sm = await new EmptyCollectModule__factory(user).deploy(assetHub)
    const smAdrr = await sm.getAddress()
    await expect(assetHub.setCollectModuleWhitelist(smAdrr, true))
      .to.be.revertedWithCustomError(assetHub, ERRORS.OwnableUnauthorizedAccount)
      .withArgs(userAddress)
  })

  it("should set collect module whitelist by admin", async function () {
    const sm = await new EmptyCollectModule__factory(user).deploy(cts.assetHub)
    const smAdrr = await sm.getAddress()
    const adminAssertHub = cts.assetHub.connect(deployer)
    await expect(adminAssertHub.setCollectModuleWhitelist(smAdrr, true)).to.not.be.reverted
  })

  it("isCollectModuleWhitelisted should return true after set collect module whitelist", async function () {
    const adminAssertHub = cts.assetHub.connect(deployer)
    const sm = await new EmptyCollectModule__factory(user).deploy(cts.assetHub)
    const smAdrr = await sm.getAddress()

    expect(await adminAssertHub.collectModuleWhitelisted(smAdrr)).to.be.false
    await expect(adminAssertHub.setCollectModuleWhitelist(smAdrr, true))
      .to.not.be.reverted
    expect(await adminAssertHub.collectModuleWhitelisted(smAdrr)).to.be.true
  })

  it("should revert when create asset with a collect module that is not whitelisted", async function () {
    const sm = await new EmptyCollectModule__factory(user).deploy(cts.assetHub)
    const smAdrr = await sm.getAddress()
    const assetHub = cts.assetHub.connect(user)
    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      collectModule: smAdrr,
      collectModuleInitData: ZERO_DATA,
      assetCreateModuleData: ZERO_DATA,
      gatedModule: ZeroAddress,
      gatedModuleInitData: ZERO_DATA,
    })).to.be.revertedWithCustomError(assetHubLogic, ERRORS.CollectModuleNotWhitelisted)
  })

  it("should created asset with a collect module that is whitelisted", async function () {
    const sm = await new EmptyCollectModule__factory(user).deploy(cts.assetHub)
    const smAdrr = await sm.getAddress()

    const adminAssertHub = cts.assetHub.connect(deployer)
    await expect(adminAssertHub.setCollectModuleWhitelist(smAdrr, true)).to.not.be.reverted

    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      collectModule: smAdrr,
      collectModuleInitData: ZERO_DATA,
      assetCreateModuleData: ZERO_DATA,
      gatedModule: ZeroAddress,
      gatedModuleInitData: ZERO_DATA,
    })).to.not.be.reverted
  })
})