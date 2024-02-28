import { expect } from "chai";
import { AssetHubFactory, AssetHubFactory__factory, AssetHub__factory, FeeCollectModule__factory, NftAssetGatedModule__factory } from "../../typechain-types";
import { deployer } from "../setup.spec";

describe("AssetHubFactory", async function () {
  let factory: AssetHubFactory;

  beforeEach(async function () {
    const assetHubImpl = await new AssetHub__factory(deployer).deploy();
    const feeCollectImpl = await new FeeCollectModule__factory(deployer).deploy();
    const nftGatedModuleImpl = await new NftAssetGatedModule__factory(deployer).deploy();
    factory = await new AssetHubFactory__factory(deployer).deploy();
    await expect(factory.initialize({
      assetHubImpl: await assetHubImpl.getAddress(),
      feeCollectModuleImpl: await feeCollectImpl.getAddress(),
      nftGatedModuleImpl: await nftGatedModuleImpl.getAddress(),
    })).to.not.be.reverted;
  });

  it("should deploy a new assethub", async function () {
    await expect(factory.deploy({
      admin: await deployer.getAddress(),
      name: "Test AssetHub",
      collectNft: true,
    })).to.not.be.reverted;
  });
});