import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { AssetHub, FeeSubscribeModule, FeeSubscribeModule__factory } from "../../typechain-types"
import { DeployCtx, deployContracts, deployer, user, userAddress } from "../setup.spec"
import { expect } from "chai"
import { AbiCoder, AddressLike, BytesLike, ZeroAddress } from "ethers"
import { ZERO_DATA } from "../contants"
import { ERRORS } from "../helpers/errors"
function createAsset(hub: AssetHub, module: AddressLike, initData: BytesLike) {
  return hub.create({
    publisher: ZeroAddress,
    contentURI: "https://www.google.com",
    subscribeModule: module,
    subscribeModuleInitData: initData,
  })
}
describe("Subcribe to Asset with fee module", async () => {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  const firstAssetId = 1
  let feeModule: FeeSubscribeModule = {} as any

  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHubImpl.connect(user)
    feeModule = await new FeeSubscribeModule__factory(user).deploy(await assetHub.getAddress())
    const adminHub = cts.assetHubImpl.connect(deployer)
    await expect(adminHub.subscribeModuleWhitelist(await feeModule.getAddress(), true))
      .to.not.be.reverted
  })

  it("should fail to create asset with unwhitelisted fee subscribe module", async function () {
    const unwhitelistedFeeModule = await new FeeSubscribeModule__factory(user)
      .deploy(await assetHub.getAddress())
    await expect(createAsset(assetHub, await unwhitelistedFeeModule.getAddress(), ZERO_DATA))
      .to.be.revertedWithCustomError(assetHub, ERRORS.SubscribeModuleNotWhitelisted)
  })

  it("should subscribe to asset with fee module", async function () {
    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "address", "uint256"],
      [await cts.tokenImpl.getAddress(), userAddress, 10]
    )
    await expect(createAsset(assetHub, await feeModule.getAddress(), initData))
      .to.not.be.reverted
    const bt = await assetHub.subscribe(firstAssetId, ZERO_DATA)
    expect(bt).to.be.gt(0)
    expect(await assetHub.subscribedCount(firstAssetId, user)).to.be.equal(1)
  })
})

