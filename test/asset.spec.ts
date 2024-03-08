import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { DeployCtx, accounts, deployContracts, deployer, user, userAddress } from "./setup.spec";
import { AssetHub } from "../typechain-types";
import { ZeroAddress } from "ethers";
import { ZERO_DATA } from "./contants";

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
    expect(await assetHub.tokenURI(1)).to.be.equal("https://www.google.com")
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

    it("should create asset of the third publisher with owner", async function () {
      const thirdUser = accounts[2]
      const ownerHub = cts.assetHub.connect(deployer)
      await expect(ownerHub.create({
        publisher: thirdUser,
        contentURI: "https://www.google.com",
        collectModule: ZeroAddress,
        collectModuleInitData: "0x",
        assetCreateModuleData: ZERO_DATA,
        gatedModule: ZeroAddress,
        gatedModuleInitData: ZERO_DATA,
      })).to.be.not.reverted
    })
  })
})