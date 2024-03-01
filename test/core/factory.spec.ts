import { expect } from "chai";
import { AssetHubFactory__factory, AssetHubManager, AssetHubManager__factory, FeeCollectModuleFactory__factory, FeeCollectModule__factory, FeeCreateAssetModuleFactory__factory, NftAssetGatedModuleFactory__factory, NftAssetGatedModule__factory } from "../../typechain-types";
import { assethubLibs, deployer } from "../setup.spec";

describe("AssetHubFactory", async function () {
  let factory: AssetHubManager;

  beforeEach(async function () {
    factory = await new AssetHubManager__factory(deployer).deploy();
    const assetHubFactory = await new AssetHubFactory__factory(assethubLibs, deployer).deploy();
    const feeCollectModuleFactory = await new FeeCollectModuleFactory__factory(deployer).deploy();
    const nftGatedModuleFactory = await new NftAssetGatedModuleFactory__factory(deployer).deploy();
    const FeeAssetCreateModule = await new FeeCreateAssetModuleFactory__factory(deployer).deploy();
    await expect(factory.initialize({
      assetHubFactory: await assetHubFactory.getAddress(),
      feeCollectModuleFactory: await feeCollectModuleFactory.getAddress(),
      nftGatedModuleFactory: await nftGatedModuleFactory.getAddress(),
      feeCreateAssetModuleFactory: await FeeAssetCreateModule.getAddress()
    })).to.not.be.reverted;
  });

  it("should deploy a new assethub", async function () {
    await expect(factory.deploy({
      admin: await deployer.getAddress(),
      name: "Test AssetHub",
      collectNft: true
    })).to.not.be.reverted;
  });
});