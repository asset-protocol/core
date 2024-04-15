import { loadFixture, time } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { AssetHub, OneTokenCollectModule, OneTokenCollectModule__factory, TokenCollectModule, TokenCollectModule__factory } from "../../../typechain-types"
import { DeployCtx, assetHubLogic, deployContracts, deployer, hubManager, user, user3, userAddress } from "../../setup.spec"
import { expect } from "chai"
import { AbiCoder, ZeroAddress, parseEther } from "ethers"
import { ZERO_DATA } from "../../contants"
import { ERRORS } from "../../helpers/errors"
import { createAsset, createAssetStatic } from "../../helpers/asset"
import { ethers } from "hardhat"

describe("Collect Asset with ONE token collect module", async () => {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  let tokenCollectModule: OneTokenCollectModule = {} as any
  let assetId: bigint
  let assetCollectNFT: string
  const SubcribeFree = 10

  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHub.connect(user)
    tokenCollectModule = await new OneTokenCollectModule__factory(user).deploy()
    await tokenCollectModule.initialize(await hubManager.getAddress())
    const adminHub = cts.assetHub.connect(deployer)
    await expect(adminHub.setCollectModuleWhitelist(await tokenCollectModule.getAddress(), true))
      .to.not.be.reverted

    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "address", "uint256"],
      [await cts.tokenImpl.getAddress(), userAddress, SubcribeFree]
    )
    assetId = await createAssetStatic(assetHub, await tokenCollectModule.getAddress(), initData);
    await expect(await createAsset(assetHub, await tokenCollectModule.getAddress(), initData))
      .to.not.be.reverted
    assetCollectNFT = await assetHub.assetCollectNFT(assetId)
  })

  it("should fail to create asset with unwhitelisted token collect module", async function () {
    const unwhitelistedTokenModule = await new OneTokenCollectModule__factory(user)
      .deploy()
    await unwhitelistedTokenModule.initialize(await hubManager.getAddress())
    await expect(createAsset(assetHub, await unwhitelistedTokenModule.getAddress(), ZERO_DATA))
      .to.be.revertedWithCustomError(assetHubLogic, ERRORS.CollectModuleNotWhitelisted)
  })

  it("should create a asset with token collect module", async function () {
    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "address", "uint256"],
      [await cts.tokenImpl.getAddress(), userAddress, 10]
    )
    const assetId = await createAssetStatic(assetHub, await tokenCollectModule.getAddress(), initData);
    await expect(await createAsset(assetHub, await tokenCollectModule.getAddress(), initData))
      .to.not.be.reverted
    const fc = await tokenCollectModule.getConfig(await assetHub.getAddress(), assetId)
    expect(fc.amount).to.be.eq(10)
    expect(fc.currency).to.be.eq(await cts.tokenImpl.getAddress())
    expect(fc.recipient).to.be.eq(userAddress)
  })

  it("should not collect a asset with token collect module when InsufficientAllowance", async function () {
    const bt = await time.latest()
    const use3hub = assetHub.connect(user3)
    await expect(use3hub.collect(assetId, ZERO_DATA))
      .to.be.revertedWithCustomError(cts.tokenImpl, "ERC20InsufficientAllowance")
      .withArgs(await tokenCollectModule.getAddress(), 0, SubcribeFree)
  })

  it("should not collect a asset with token collect module when ERC20InsufficientBalance", async function () {
    const use3hub = assetHub.connect(user3)
    await expect(cts.tokenImpl.mint(await user3.getAddress(), 5))
      .to.not.be.reverted
    await expect(cts.tokenImpl.connect(user3).approve(await tokenCollectModule.getAddress(), 10))
      .to.not.be.reverted
    await expect(use3hub.collect(assetId, ZERO_DATA))
      .to.be.revertedWithCustomError(cts.tokenImpl, "ERC20InsufficientBalance")
      .withArgs(await user3.getAddress(), 5, SubcribeFree)
  })

  it("should collect a asset with token collect module", async function () {
    const use3hub = assetHub.connect(user3)
    const user3Address = await user3.getAddress()
    const tokenAddress = await tokenCollectModule.getAddress()
    await expect(cts.tokenImpl.mint(user3Address, 10))
      .to.not.be.reverted
    await expect(cts.tokenImpl.connect(user3).approve(tokenAddress, 10))
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
        await tokenCollectModule.getAddress(),
        ZERO_DATA,
        bt + 1
      )
  })

  it("should collect a asset with token collect module after update", async function () {
    const use3hub = assetHub.connect(user3)
    const user3Address = await user3.getAddress()
    const tokenAddress = await tokenCollectModule.getAddress()

    const fee = parseEther("1")

    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "address", "uint256"],
      [await cts.tokenImpl.getAddress(), userAddress, fee]
    )

    await expect(assetHub.update(assetId, {
      contentURI: "",
      collectModule: tokenAddress,
      collectModuleInitData: initData,
      gatedModule: ZeroAddress,
      gatedModuleInitData: "0x",
    })).to.not.be.reverted

    await expect(cts.tokenImpl.mint(user3Address, fee))
      .to.not.be.reverted
    await expect(cts.tokenImpl.connect(user3).approve(tokenAddress, fee))
      .to.not.be.reverted
    await expect(use3hub.collect(assetId, ZERO_DATA))
      .to.not.be.reverted;
  })
})



