import { loadFixture, setBalance } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { AbiCoder, ZeroAddress } from "ethers";
import { AssetHub, OneFeeCollectModule, OneFeeCollectModule__factory } from "../../../typechain-types";
import { createAssetStatic, createAsset } from "../../helpers/asset";
import { DeployCtx, deployContracts, deployer, hubManager, user, user3, userAddress } from "../../setup.spec";
import { ethers } from "hardhat";

describe("Collect Asset with one fee collect module", async () => {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  let feeCollectModule: OneFeeCollectModule = {} as any
  let assetId: bigint
  let assetCollectNFT: string
  const collectFree = 10

  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHub.connect(user)
    feeCollectModule = await new OneFeeCollectModule__factory(user).deploy()
    await feeCollectModule.initialize(await hubManager.getAddress())
    const adminHub = cts.assetHub.connect(deployer)
    await adminHub.setCollectModuleWhitelist(await feeCollectModule.getAddress(), true);

    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "uint256"],
      [ZeroAddress, collectFree]
    )
    assetId = await createAssetStatic(assetHub, await feeCollectModule.getAddress(), initData);
    await expect(await createAsset(assetHub, await feeCollectModule.getAddress(), initData))
      .to.not.be.reverted
    assetCollectNFT = await assetHub.assetCollectNFT(assetId)
  })

  it("should fail to create asset with unwhitelisted fee collect module", async function () {
    const unwhitelistedFeeModule = await new OneFeeCollectModule__factory(user)
      .deploy()
    await unwhitelistedFeeModule.initialize(await hubManager.getAddress())
    await expect(createAsset(assetHub, await unwhitelistedFeeModule.getAddress(), ZeroAddress))
      .to.be.reverted
  })

  it("should collect an asset with enough fee", async function () {
    const user3Address = await user3.getAddress();
    await setBalance(userAddress, 0);
    expect(await ethers.provider.getBalance(userAddress)).to.be.equal(0)
    await expect(assetHub.connect(user3).collect(assetId, "0x", { value: BigInt(collectFree) }))
      .to.changeEtherBalance(user3Address, -collectFree)
    expect(await ethers.provider.getBalance(userAddress)).to.be.equal(collectFree)
  })

  it("Trasnfer fee to new owner if asset is transferred", async function () {
    const user3Address = await user3.getAddress();
    await expect(assetHub.transferFrom(userAddress, user3Address, assetId)).to.not.be.reverted
    expect(await assetHub.ownerOf(assetId)).to.be.equal(user3Address)
    await setBalance(user3Address, 0);
    await expect(assetHub.connect(user).collect(assetId, "0x", { value: BigInt(collectFree) }))
      .to.changeEtherBalance(userAddress, -collectFree)
    expect(await ethers.provider.getBalance(user3Address)).to.be.equal(collectFree)
  })

  it("Transfer fee to the recipent when asset create set", async function () {
    const user3Address = await user3.getAddress();
    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "uint256"],
      [user3Address, collectFree]
    )
    const userHub = assetHub.connect(user);
    const userAssetId = await createAssetStatic(userHub, await feeCollectModule.getAddress(), initData);
    await expect(await createAsset(userHub, await feeCollectModule.getAddress(), initData))
      .to.not.be.reverted

    await setBalance(user3Address, 0);
    await expect(assetHub.connect(deployer).collect(userAssetId, "0x", { value: BigInt(collectFree) }))
      .to.changeEtherBalance(await deployer.getAddress(), -collectFree)
    expect(await ethers.provider.getBalance(user3Address)).to.be.equal(collectFree)
  })

  it("should collect an asset with enough fee after updated asset", async () => {
    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "uint256"],
      [ZeroAddress, 5]
    )
    await expect(assetHub.update(assetId, {
      contentURI: "",
      collectModule: await feeCollectModule.getAddress(),
      collectModuleInitData: initData,
      gatedModule: ZeroAddress,
      gatedModuleInitData: "0x",
    })).to.not.be.reverted;
    const user3Address = await user3.getAddress();
    await setBalance(userAddress, 0);
    expect(await ethers.provider.getBalance(userAddress)).to.be.equal(0)
    await expect(assetHub.connect(user3).collect(assetId, "0x", { value: BigInt(5) }))
      .to.changeEtherBalance(user3Address, -5)
    expect(await ethers.provider.getBalance(userAddress)).to.be.equal(5)
  })
});