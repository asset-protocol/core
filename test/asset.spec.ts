import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { DeployCtx, accounts, deployContracts, deployer, deployerAddress, hubManager, user, userAddress } from "./setup.spec";
import { AssetHub } from "../typechain-types";
import { AbiCoder, ZeroAddress } from "ethers";
import { IGNORE_ADDRESS, ZERO_DATA } from "./contants";
import { createAsset, createAssetStatic } from "./helpers/asset";

const CURRENT_ASSETHUB_VERSION = "0.2.1";

describe("Upgrade hub", async () => {
  let cts: DeployCtx = {} as any
  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
  })

  it("version should increase when upgrade hub", async () => {
    const nextHub = await hubManager.createHubImpl.staticCall(ZERO_DATA);
    await expect(hubManager.createHubImpl(ZERO_DATA)).to.not.be.reverted;
    await expect(cts.assetHub.upgradeToAndCall(nextHub, ZERO_DATA)).to.not.be.reverted;
    expect(await cts.assetHub.version()).to.be.equal(CURRENT_ASSETHUB_VERSION);
  })
});

describe("Create Asset", async () => {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
  })

  it("should create asset", async function () {
    assetHub = cts.assetHub.connect(user)
    await expect(assetHub.create({
      publisher: ZeroAddress,
      contentURI: "https://www.google.com",
      collectModule: ZeroAddress,
      collectModuleInitData: ZERO_DATA,
      assetCreateModuleData: ZERO_DATA,
      gatedModule: ZeroAddress,
      gatedModuleInitData: ZERO_DATA,
    })).to.not.be.reverted;
    expect(await assetHub.balanceOf(userAddress)).to.be.equal(1)
    expect(await assetHub.count(userAddress)).to.be.equal(1)
    expect(await assetHub.tokenURI(0)).to.be.equal("https://www.google.com")
  })


  it("should create asset with other publisher", async function () {
    const thirdUser = accounts[2]
    await expect(assetHub.create({
      publisher: thirdUser,
      contentURI: "https://www.google.com",
      collectModule: ZeroAddress,
      collectModuleInitData: "0x",
      assetCreateModuleData: ZERO_DATA,
      gatedModule: ZeroAddress,
      gatedModuleInitData: ZERO_DATA,
    })).to.not.be.reverted;
  })

  it("should create asset of the third publisher with owner", async function () {
    const thirdUser = accounts[2]
    const ownerHub = cts.assetHub.connect(deployer)
    await expect(ownerHub.create({
      publisher: thirdUser,
      contentURI: "https://www.google.com",
      collectModule: ZeroAddress,
      collectModuleInitData: ZERO_DATA,
      assetCreateModuleData: ZERO_DATA,
      gatedModule: ZeroAddress,
      gatedModuleInitData: ZERO_DATA,
    })).to.be.not.reverted
  })

  it("should update asset", async function () {
    assetHub = cts.assetHub.connect(user)
    const tokenId = await createAssetStatic(assetHub, ZeroAddress, ZERO_DATA);
    await expect(createAsset(assetHub, ZeroAddress, ZERO_DATA)).to.not.be.reverted;

    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "address", "uint256"],
      ["0xc2ADF187D9B064F68FcD8183195cddDB33E10E8F", ZeroAddress, 10]
    )
    await expect(assetHub.update(tokenId, {
      contentURI: "https://www.baidu.com",
      collectModule: cts.tokenCollectModule,
      collectModuleInitData: initData,
      gatedModule: IGNORE_ADDRESS,
      gatedModuleInitData: ZERO_DATA,
    })).to.not.be.reverted;
  })

  it("should update asset without update", async function () {
    assetHub = cts.assetHub.connect(user)
    const tokenId = await createAssetStatic(assetHub, ZeroAddress, ZERO_DATA);
    await expect(createAsset(assetHub, ZeroAddress, ZERO_DATA)).to.not.be.reverted;
    await expect(assetHub.update(tokenId, {
      contentURI: "",
      collectModule: IGNORE_ADDRESS,
      collectModuleInitData: ZERO_DATA,
      gatedModule: IGNORE_ADDRESS,
      gatedModuleInitData: ZERO_DATA,
    })).to.not.be.reverted;
  })
})