import { expect } from "chai"
import { DeployCtx, assetCuration, deployContracts, user, user3 } from "../setup.spec"
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { createAsset, createTestAsset } from "../helpers/asset"
import { AssetHub } from "../../typechain-types"

const AssetApproving = 0;
const AssetApproved = 1;
const AssetRejected = 2;

describe("Test Curation", () => {
  let ctx: DeployCtx = {} as any;
  let ctx2: DeployCtx = {} as any;
  let assetHub: AssetHub;
  let hubAddress: string;
  let asset1: bigint;
  let asset2: bigint;
  let asset3: bigint;
  let assetHub2: AssetHub;
  let assetHub2Address: string;
  let hub2Asset1: bigint;
  let hub2Asset2: bigint;
  before(async () => {
    ctx = await loadFixture(deployContracts);
    ctx2 = await loadFixture(deployContracts);
    assetHub = ctx.assetHub.connect(user);
    asset1 = await createTestAsset(assetHub);
    asset2 = await createTestAsset(assetHub);
    asset3 = await createTestAsset(assetHub);
    hubAddress = await assetHub.getAddress();

    assetHub2 = ctx2.assetHub.connect(user3);
    assetHub2Address = await assetHub2.getAddress();
    hub2Asset1 = await createTestAsset(assetHub2);
    hub2Asset2 = await createTestAsset(assetHub2);
  })

  it("should create a curation without assets", async () => {
    await expect(assetCuration.create("https://baidu.com", 0n, [])).to.not.be.reverted;
  })

  it("should create a curation with assets in a same hub", async () => {
    await expect(assetCuration.create("https://baidu.com", 0n, [
      {
        assetId: asset1,
        hub: hubAddress,
        order: 0n
      },
      {
        assetId: asset2,
        hub: hubAddress,
        order: 0n
      }
    ])).to.not.be.reverted;
  });

  it("should create a curation with assets in different hubs", async () => {
    await expect(assetCuration.create("https://baidu.com", 0n, [
      {
        assetId: asset1,
        hub: hubAddress,
        order: 0n
      },
      {
        assetId: hub2Asset1,
        hub: assetHub2Address,
        order: 0n
      },
      {
        assetId: asset1,
        hub: hubAddress,
        order: 0n
      }
    ])).to.not.be.reverted;
  })

  it("asset should be not appoved by default", async () => {
    const curationId = await createTestCuration();
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(2);
    curation.assets.forEach((asset) => {
      expect(asset.status).to.equal(AssetApproving);
    });
  })

  it("approve asset should be reverted when user is not asset owner", async () => {
    const curationId = await createTestCuration();
    await expect(assetCuration.connect(user).approveAsset(curationId, assetHub2Address, hub2Asset1, AssetApproved)).to.be.reverted;
  })

  it("asset should be approved by owner", async () => {
    const curationId = await createTestCuration();
    await expect(assetCuration.connect(user3).approveAsset(curationId, assetHub2Address, hub2Asset1, AssetApproved)).to.not.be.reverted;
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(2);
    const asset2 = curation.assets.find(a => a.assetId === hub2Asset1 && a.hub === assetHub2Address);
    expect(asset2).to.not.be.undefined;
    expect(asset2!.status).to.equal(AssetApproved);
  })

  it("asset should be rejected by owner", async () => {
    const curationId = await createTestCuration();
    await expect(assetCuration.connect(user3).approveAsset(curationId, assetHub2Address, hub2Asset1, AssetRejected)).to.not.be.reverted;
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(2);
    const asset2 = curation.assets.find(a => a.assetId === hub2Asset1 && a.hub === assetHub2Address);
    expect(asset2).to.not.be.undefined;
    expect(asset2!.status).to.equal(AssetRejected);
  })


  it("add asset should be reverted when user is not asset owner", async () => {
    const curationId = await assetCuration.create.staticCall("https://baidu.com", 0n, []);
    await expect(assetCuration.create("https://baidu.com", 0n, [])).to.not.be.reverted;
    await expect(assetCuration.connect(user3).addAssets(curationId, [{
      assetId: asset1,
      hub: hubAddress,
      order: 0n
    },
    {
      assetId: hub2Asset1,
      hub: assetHub2Address,
      order: 0n
    }])).to.be.reverted;
  })

  it("add assets to curation", async () => {
    const curationId = await assetCuration.create.staticCall("https://baidu.com", 0n, []);
    await expect(assetCuration.create("https://baidu.com", 0n, [])).to.not.be.reverted;
    await assetCuration.addAssets(curationId, [{
      assetId: asset1,
      hub: hubAddress,
      order: 0n
    },
    {
      assetId: hub2Asset1,
      hub: assetHub2Address,
      order: 0n
    }]);
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(2);
  })

  it("remove assets to curation", async () => {
    const curationId = await createTestCuration();
    await assetCuration.removeAssets(curationId, [hubAddress], [asset1]);
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(1);
    expect(curation.assets[0].assetId).to.be.equal(hub2Asset1);
  })

  async function createTestCuration() {
    const createData = [
      {
        assetId: asset1,
        hub: hubAddress,
        order: 0n
      },
      {
        assetId: hub2Asset1,
        hub: assetHub2Address,
        order: 0n
      }
    ]
    const curationId = await assetCuration.create.staticCall("https://baidu.com", 0n, createData);
    await expect(assetCuration.create("https://baidu.com", 0n, createData)).to.not.be.reverted;
    return curationId;
  }
})

