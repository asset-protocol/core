import { expect } from 'chai';
import { DeployCtx, assetCuration, deployContracts, user, user3 } from '../setup.spec';
import { loadFixture, time } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { createTestAsset } from '../helpers/asset';
import { AssetHub } from '../../typechain-types';

const AssetApproving = 0;
const AssetApproved = 1;
const AssetRejected = 2;
const AssetExpired = 3;

describe('Test Curation', () => {
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
  });

  it('should create a curation without assets', async () => {
    await expect(assetCuration.create('https://baidu.com', 0n, 0n, [])).to.not.be.reverted;
  });

  it('should create a curation with assets in a same hub', async () => {
    await expect(
      assetCuration.create('https://baidu.com', 0n, 0n, [
        {
          assetId: asset1,
          hub: hubAddress,
        },
        {
          assetId: asset2,
          hub: hubAddress,
        },
      ])
    ).to.not.be.reverted;
  });

  it('should create a curation with assets in different hubs', async () => {
    await expect(
      assetCuration.create('https://baidu.com', 0n, 0n, [
        {
          assetId: asset1,
          hub: hubAddress,
        },
        {
          assetId: hub2Asset1,
          hub: assetHub2Address,
        },
        {
          assetId: asset1,
          hub: hubAddress,
        },
      ])
    ).to.not.be.reverted;
  });

  it('asset should be not appoved by default', async () => {
    const curationId = await createTestCuration();
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(2);
    curation.assets.forEach((asset) => {
      expect(asset.status).to.equal(AssetApproving);
    });
  });

  it('approve asset should be reverted when user is not asset owner', async () => {
    const curationId = await createTestCuration();
    await expect(
      assetCuration
        .connect(user)
        .approveAsset(curationId, assetHub2Address, hub2Asset1, AssetApproved)
    ).to.be.reverted;
  });

  it('asset should be approved by owner', async () => {
    const curationId = await createTestCuration();
    await expect(
      assetCuration
        .connect(user3)
        .approveAsset(curationId, assetHub2Address, hub2Asset1, AssetApproved)
    ).to.not.be.reverted;
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(2);
    const asset2 = curation.assets.find(
      (a) => a.assetId === hub2Asset1 && a.hub === assetHub2Address
    );
    expect(asset2).to.not.be.undefined;
    expect(asset2!.status).to.equal(AssetApproved);
  });

  it('asset should be rejected by owner', async () => {
    const curationId = await createTestCuration();
    await expect(
      assetCuration
        .connect(user3)
        .approveAsset(curationId, assetHub2Address, hub2Asset1, AssetRejected)
    ).to.not.be.reverted;
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(2);
    const asset2 = curation.assets.find(
      (a) => a.assetId === hub2Asset1 && a.hub === assetHub2Address
    );
    expect(asset2).to.not.be.undefined;
    expect(asset2!.status).to.equal(AssetRejected);
  });

  it('add asset should be reverted when user is not asset owner', async () => {
    const curationId = await assetCuration.create.staticCall('https://baidu.com', 0n, 0n, []);
    await expect(assetCuration.create('https://baidu.com', 0n, 0n, [])).to.not.be.reverted;
    await expect(
      assetCuration.connect(user3).addAssets(curationId, [
        {
          assetId: asset1,
          hub: hubAddress,
        },
        {
          assetId: hub2Asset1,
          hub: assetHub2Address,
        },
      ])
    ).to.be.reverted;
  });

  it('add assets to curation', async () => {
    const curationId = await assetCuration.create.staticCall('https://baidu.com', 0n, 0n, []);
    await expect(assetCuration.create('https://baidu.com', 0n, 0n, [])).to.not.be.reverted;
    await assetCuration.addAssets(curationId, [
      {
        assetId: asset1,
        hub: hubAddress,
      },
      {
        assetId: hub2Asset1,
        hub: assetHub2Address,
      },
    ]);
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(2);
  });

  it('remove assets to curation', async () => {
    const curationId = await createTestCuration();
    await assetCuration.removeAssets(curationId, [hubAddress], [asset1]);
    const curation = await assetCuration.curationData(curationId);
    expect(curation.assets.length).to.be.equal(1);
    expect(curation.assets[0].assetId).to.be.equal(hub2Asset1);
  });

  it('get an asset status', async () => {
    const curationId = await createTestCuration();
    const status = await assetCuration.assetsStatus(curationId, [hubAddress], [asset1]);
    expect(status.length).to.equal(1);
    expect(status[0]).to.equal(AssetApproving);
    await expect(
      assetCuration
        .connect(user3)
        .approveAsset(curationId, assetHub2Address, hub2Asset1, AssetApproved)
    ).to.not.be.reverted;
    const status2 = await assetCuration.assetsStatus(curationId, [assetHub2Address], [hub2Asset1]);
    expect(status2.length).to.equal(1);
    expect(status2[0]).to.equal(AssetApproved);
  });

  it('get many assets status', async () => {
    const curationId = await createTestCuration();
    const statuses = await assetCuration.assetsStatus(
      curationId,
      [hubAddress, assetHub2Address],
      [asset1, hub2Asset1]
    );
    expect(statuses.length).to.equal(2);
    expect(statuses[0]).to.equal(AssetApproving);
    expect(statuses[1]).to.equal(AssetApproving);
    await expect(
      assetCuration
        .connect(user3)
        .approveAsset(curationId, assetHub2Address, hub2Asset1, AssetApproved)
    ).to.not.be.reverted;
    const statuses2 = await assetCuration.assetsStatus(
      curationId,
      [hubAddress, assetHub2Address],
      [asset1, hub2Asset1]
    );
    expect(statuses2.length).to.equal(2);
    expect(statuses2[0]).to.equal(AssetApproving);
    expect(statuses2[1]).to.equal(AssetApproved);
  });

  it('get many assets status after curation expired', async () => {
    const ts = await time.latest();
    const curationId = await createTestCuration(BigInt(ts + 24 * 60 * 60));
    await expect(
      assetCuration.connect(user).approveAsset(curationId, hubAddress, asset1, AssetApproved)
    ).to.not.be.reverted;
    await expect(
      assetCuration
        .connect(user3)
        .approveAsset(curationId, assetHub2Address, hub2Asset1, AssetRejected)
    ).to.not.be.reverted;
    await time.increase(24 * 60 * 60 * 2);
    const statuses = await assetCuration.assetsStatus(
      curationId,
      [hubAddress, assetHub2Address],
      [asset1, hub2Asset1]
    );
    expect(statuses.length).to.equal(2);
    expect(statuses[0]).to.equal(AssetExpired);
    expect(statuses[1]).to.equal(AssetRejected);
  });

  it('The asset approved status should be expired after update expired curation expiry', async () => {
    const ts = await time.latest();
    const curationId = await createTestCuration(BigInt(ts + 24 * 60 * 60));
    await expect(
      assetCuration.connect(user).approveAsset(curationId, hubAddress, asset1, AssetApproved)
    ).to.not.be.reverted;
    await time.increase(24 * 60 * 60 * 2);
    const ts2 = await time.latest();
    await assetCuration.setExpiry(curationId, BigInt(ts2 + 24 * 60 * 60));
    const statuses = await assetCuration.assetsStatus(
      curationId,
      [hubAddress, assetHub2Address],
      [asset1, hub2Asset1]
    );
    expect(statuses.length).to.equal(2);
    expect(statuses[0]).to.equal(AssetExpired);
    expect(statuses[1]).to.equal(AssetApproving);
  });

  async function createTestCuration(expired?: bigint) {
    const createData = [
      {
        assetId: asset1,
        hub: hubAddress,
      },
      {
        assetId: hub2Asset1,
        hub: assetHub2Address,
      },
    ];
    const curationId = await assetCuration.create.staticCall(
      'https://baidu.com',
      0n,
      expired ?? 0n,
      createData
    );
    await expect(assetCuration.create('https://baidu.com', 0n, expired ?? 0n, createData)).to.not.be
      .reverted;
    return curationId;
  }
});
