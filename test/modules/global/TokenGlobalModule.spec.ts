import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { DeployCtx, deployContracts, deployerAddress, testToken, tokenGlobalModule, user, userAddress } from "../../setup.spec";
import { expect } from "chai";
import { createAsset, createAssetStatic } from "../../helpers/asset";
import { ZeroAddress } from "ethers";
import { ZERO_DATA } from "../../contants";

describe("Test collect asset with token global module", () => {
  let cts: DeployCtx = {} as any
  let assetId: bigint;

  beforeEach(async function () {
    cts = await loadFixture(deployContracts);
    const assetHub = cts.assetHub.connect(user);
    assetId = await createAssetStatic(assetHub, ZeroAddress, ZERO_DATA);
    await expect(await createAsset(assetHub, ZeroAddress, ZERO_DATA))
      .to.not.be.reverted
  });


  it("Should not collect with token global module", async () => {
    await expect(cts.assetHub.collect(assetId, ZERO_DATA)).to.not.be.reverted;
    // set global collect fee when collect asset
    const hubAddress = await cts.assetHub.getAddress();
    await expect(tokenGlobalModule.setCollectFee(hubAddress, 10)).to.not.be.reverted;
    // collect failed when need token global module
    await expect(cts.assetHub.collect(assetId, ZERO_DATA)).to.be.reverted;
  });

  it("Should collect with 0 fee token global module", async () => {
    // set global collect fee to zero when collect asset
    const hubAddress = await cts.assetHub.getAddress();
    await expect(tokenGlobalModule.setCollectFee(hubAddress, 0)).to.not.be.reverted;
    await expect(cts.assetHub.collect(assetId, ZERO_DATA)).to.not.be.reverted;
  });

  it("Should not collect asset with token global module when has not enough token", async () => {
    const hubAddress = await cts.assetHub.getAddress();
    await expect(tokenGlobalModule.setCollectFee(hubAddress, 10)).to.not.be.reverted;
    const userHub = cts.assetHub.connect(user);
    await expect(testToken.mint(await user.getAddress(), 5)).to.not.be.reverted;
    await expect(testToken.connect(user).approve(await tokenGlobalModule.getAddress(), 5)).to.not.be.reverted;
    await expect(userHub.collect(assetId, ZERO_DATA)).to.be.reverted;
  });

  it("Should collect asset with token global module when has enough token ", async () => {
    const hubAddress = await cts.assetHub.getAddress();
    await expect(tokenGlobalModule.setCollectFee(hubAddress, 10)).to.not.be.reverted;
    const userHub = cts.assetHub.connect(user);
    await expect(testToken.mint(await user.getAddress(), 10)).to.not.be.reverted;
    await expect(testToken.connect(user).approve(await tokenGlobalModule.getAddress(), 10)).to.not.be.reverted;
    await expect(userHub.collect(assetId, ZERO_DATA)).to.not.be.reverted;
  });
});

describe("Test create asset with token global module", () => {
  let cts: DeployCtx = {} as any

  beforeEach(async function () {
    cts = await loadFixture(deployContracts);
  });


  it("Should not create asset with token global module", async () => {
    const assetHub = cts.assetHub.connect(user);
    await expect(createAsset(assetHub, ZeroAddress, ZERO_DATA)).to.not.be.reverted;
    const hubAddress = await cts.assetHub.getAddress();
    // set global collect fee when collect asset
    await expect(tokenGlobalModule.setCreateFee(hubAddress, 10)).to.not.be.reverted;
    await expect(createAsset(assetHub, ZeroAddress, ZERO_DATA)).to.be.reverted;
  });

  it("Should create asset with 0 fee token global module", async () => {
    const hubAddress = await cts.assetHub.getAddress();
    const assetHub = cts.assetHub.connect(user);
    // set global collect fee to zero when collect asset
    await expect(tokenGlobalModule.setCreateFee(hubAddress, 0)).to.not.be.reverted;
    await expect(createAsset(assetHub, ZeroAddress, ZERO_DATA)).to.not.be.reverted;
  });

  it("Should not create asset with token global module when has not enough token", async () => {
    const hubAddress = await cts.assetHub.getAddress();
    const assetHub = cts.assetHub.connect(user);
    await expect(tokenGlobalModule.setCreateFee(hubAddress, 10)).to.not.be.reverted;
    await expect(testToken.mint(hubAddress, 5)).to.not.be.reverted;
    await expect(testToken.connect(user).approve(await tokenGlobalModule.getAddress(), 5)).to.not.be.reverted;
    await expect(createAsset(assetHub, ZeroAddress, ZERO_DATA)).to.be.reverted;
  });

  it("Should create asset with token global module when has enough token ", async () => {
    const hubAddress = await cts.assetHub.getAddress();
    const assetHub = cts.assetHub.connect(user);
    await expect(tokenGlobalModule.setCreateFee(hubAddress, 10)).to.not.be.reverted;
    await expect(testToken.mint(userAddress, 10)).to.not.be.reverted;
    await expect(testToken.connect(user).approve(await tokenGlobalModule.getAddress(), 10)).to.not.be.reverted;
    await expect(createAsset(assetHub, ZeroAddress, ZERO_DATA)).to.not.be.reverted;
  });
});