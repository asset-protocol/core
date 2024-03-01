import { loadFixture, time } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { AssetHub, FeeCollectModule, FeeCollectModule__factory } from "../../../typechain-types"
import { DeployCtx, deployContracts, deployer, user, user3, userAddress } from "../../setup.spec"
import { expect } from "chai"
import { AbiCoder } from "ethers"
import { ZERO_DATA } from "../../contants"
import { ERRORS } from "../../helpers/errors"
import { createAsset, createAssetStatic } from "../../helpers/asset"
import { ethers } from "hardhat"

describe("Subcribe to Asset with fee module", async () => {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  let feeModule: FeeCollectModule = {} as any
  let assetId: bigint
  let assetCollectNFT: string
  const SubcribeFree = 10

  beforeEach(async function () {
    // console.log("befere each run........................")
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHub.connect(user)
    feeModule = await new FeeCollectModule__factory(user).deploy()
    await feeModule.initialize(await assetHub.getAddress(), await user.getAddress())
    const adminHub = cts.assetHub.connect(deployer)
    await expect(adminHub.collectModuleWhitelist(await feeModule.getAddress(), true))
      .to.not.be.reverted

    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "address", "uint256"],
      [await cts.tokenImpl.getAddress(), userAddress, SubcribeFree]
    )
    assetId = await createAssetStatic(assetHub, await feeModule.getAddress(), initData);
    await expect(await createAsset(assetHub, await feeModule.getAddress(), initData))
      .to.not.be.reverted
    assetCollectNFT = await assetHub.assetCollectNFT(assetId)
  })

  it("should fail to create asset with unwhitelisted fee collect module", async function () {
    const unwhitelistedFeeModule = await new FeeCollectModule__factory(user)
      .deploy()
    await unwhitelistedFeeModule.initialize(await assetHub.getAddress(), await user.getAddress())
    await expect(createAsset(assetHub, await unwhitelistedFeeModule.getAddress(), ZERO_DATA))
      .to.be.revertedWithCustomError(assetHub, ERRORS.CollectModuleNotWhitelisted)
  })

  it("should create a asset with fee module", async function () {
    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "address", "uint256"],
      [await cts.tokenImpl.getAddress(), userAddress, 10]
    )
    const assetId = await createAssetStatic(assetHub, await feeModule.getAddress(), initData);
    await expect(await createAsset(assetHub, await feeModule.getAddress(), initData))
      .to.not.be.reverted
    const fc = await feeModule.getFeeConfig(assetId)
    expect(fc.amount).to.be.eq(10)
    expect(fc.currency).to.be.eq(await cts.tokenImpl.getAddress())
    expect(fc.recipient).to.be.eq(userAddress)
  })

  it("should not collect a asset with fee module when InsufficientAllowance", async function () {
    const bt = await time.latest()
    const use3hub = assetHub.connect(user3)
    await expect(use3hub.collect(assetId, ZERO_DATA))
      .to.be.revertedWithCustomError(cts.tokenImpl, "ERC20InsufficientAllowance")
      .withArgs(await feeModule.getAddress(), 0, SubcribeFree)
  })

  it("should not collect a asset with fee module when ERC20InsufficientBalance", async function () {
    const use3hub = assetHub.connect(user3)
    await expect(cts.tokenImpl.mint(await user3.getAddress(), 5))
      .to.not.be.reverted
    await expect(cts.tokenImpl.connect(user3).approve(await feeModule.getAddress(), 10))
      .to.not.be.reverted
    await expect(use3hub.collect(assetId, ZERO_DATA))
      .to.be.revertedWithCustomError(cts.tokenImpl, "ERC20InsufficientBalance")
      .withArgs(await user3.getAddress(), 5, SubcribeFree)
  })

  it("should collect a asset with fee module", async function () {
    const use3hub = assetHub.connect(user3)
    const user3Address = await user3.getAddress()
    const feeAddress = await feeModule.getAddress()
    await expect(cts.tokenImpl.mint(user3Address, 10))
      .to.not.be.reverted
    await expect(cts.tokenImpl.connect(user3).approve(feeAddress, 10))
      .to.not.be.reverted
    const bt = await time.latest()
    const tokenId = await use3hub.collect.staticCall(assetId, ZERO_DATA)
    const libHub = await ethers.getContractAt("AssetHubLogic", assetHub)
    await expect(use3hub.collect(assetId, ZERO_DATA))
      .to.be.emit(libHub, "Collected")
      .withArgs(
        assetId,
        user3Address,
        userAddress,
        assetCollectNFT,
        tokenId,
        await feeModule.getAddress(),
        ZERO_DATA,
        bt + 1
      )
  })
})

