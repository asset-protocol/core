import { loadFixture } from '@nomicfoundation/hardhat-toolbox/network-helpers';
import { expect } from 'chai';
import { createTestAsset } from '../../helpers/asset';
import {
  DeployCtx,
  assetCuration,
  deployContracts,
  deployHub,
  testToken,
  tokenGlobalModule,
  user,
  userAddress,
} from '../../setup.spec';
import { AssetHub } from '../../../typechain-types';

describe('Testing CurationTokenGlobalModule', () => {
  let cts: DeployCtx = {} as any;
  let assetId: bigint;
  let userAssetHub: AssetHub;

  before(async function () {
    cts = await loadFixture(deployContracts);
    userAssetHub = await deployHub(user);
    const assetHub = cts.assetHub.connect(user);
    assetId = await createTestAsset(assetHub);
  });

  it('Should not create curation with token global module', async () => {
    const curation = assetCuration.connect(user);
    await tokenGlobalModule.setCurationCreateFee(0);
    await expect(curation.create(userAssetHub, 'https://example.com', 0, 0, [])).to.not.be.reverted;
    await expect(tokenGlobalModule.setCurationCreateFee(10)).to.not.be.reverted;
    await expect(curation.create(userAssetHub, 'https://example.com', 0, 0, [])).to.be.reverted;
  });

  it('Should create curation with 0 fee token global module', async () => {
    const curation = assetCuration.connect(user);
    await expect(tokenGlobalModule.setCurationCreateFee(0)).to.not.be.reverted;
    await expect(curation.create(userAssetHub, 'https://example.com', 0, 0, [])).to.not.be.reverted;
  });

  it('Should not curation asset with token global module when has not enough token', async () => {
    const curationAddress = await assetCuration.getAddress();
    const curation = assetCuration.connect(user);
    await expect(tokenGlobalModule.setCurationCreateFee(10)).to.not.be.reverted;
    await expect(testToken.mint(curationAddress, 5)).to.not.be.reverted;
    await expect(testToken.connect(user).approve(await tokenGlobalModule.getAddress(), 5)).to.not.be
      .reverted;
    await expect(curation.create(userAssetHub, 'https://example.com', 0, 0, [])).to.be.reverted;
  });

  it('Should create curation with token global module when has enough token ', async () => {
    const curation = assetCuration.connect(user);
    await expect(tokenGlobalModule.setCurationCreateFee(10)).to.not.be.reverted;
    await expect(testToken.mint(userAddress, 10)).to.not.be.reverted;
    const balance = await testToken.balanceOf(userAddress);
    await expect(testToken.connect(user).approve(await tokenGlobalModule.getAddress(), 10)).to.not
      .be.reverted;
    await expect(curation.create(userAssetHub, 'https://example.com', 0, 0, [])).to.not.be.reverted;
    expect(await testToken.balanceOf(userAddress)).to.be.equal(balance - 10n);
  });
});
