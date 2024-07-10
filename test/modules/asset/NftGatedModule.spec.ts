import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers"
import { AssetHub, NftAssetGatedModule__factory } from "../../../typechain-types"
import { DeployCtx, deployContracts, deployer, hubManager, testErc1155, testErc721, testToken, user, user3 } from "../../setup.spec"
import { AbiCoder, ZeroAddress } from 'ethers'
import { ZERO_DATA } from "../../contants"
import { expect } from "chai"

enum NftGatedType {
  ERC20,
  ERC721,
  ERC1155
}

async function ceateAssetWithGated(
  assetHub: AssetHub,
  nftGatedModule: string,
  config: [[addr: string, t: NftGatedType, tokenId: bigint, amount: bigint, isOr: boolean]]) {
  const nftInitData = AbiCoder.defaultAbiCoder().encode(
    ["tuple(address,uint8,uint256,uint256,bool)[]"],
    [config] // 至少创建过一个 Asset
  )
  const createData = {
    publisher: ZeroAddress,
    contentURI: "https://www.google.com",
    collectModule: ZeroAddress,
    collectModuleInitData: ZERO_DATA,
    assetCreateModuleData: ZERO_DATA,
    gatedModule: nftGatedModule,
    gatedModuleInitData: nftInitData,
  }
  const assetId = await assetHub.create.staticCall(createData)
  await expect(assetHub.create(createData)).to.not.be.reverted
  return assetId
}

describe("Aesst gated with ONE NFT gated module", async () => {
  let cts: DeployCtx = {} as any
  let assetHub: AssetHub
  let nftGatedModule: string
  beforeEach(async function () {
    cts = await loadFixture(deployContracts)
    assetHub = cts.assetHub.connect(user)

    const nftGated = await new NftAssetGatedModule__factory(deployer).deploy()
    await nftGated.initialize(await hubManager.getAddress())
    nftGatedModule = await nftGated.getAddress()
  })

  it("Test asset gated with ERC20 gated module", async function () {
    const assetId = await ceateAssetWithGated(
      assetHub,
      nftGatedModule,
      [[await testToken.getAddress(), NftGatedType.ERC20, 0n, 10n, false]])
    const account = await user3.getAddress()
    expect(await assetHub.assetGated(assetId, account)).to.be.false
    await expect(testToken.mint(account, 9n)).to.not.be.reverted
    expect(await assetHub.assetGated(assetId, account)).to.be.false
    await expect(testToken.mint(account, 5n)).to.not.be.reverted
    expect(await assetHub.assetGated(assetId, account)).to.be.true
  })

  it("Test asset gated with ERC721 gated module", async function () {
    const assetId = await ceateAssetWithGated(
      assetHub,
      nftGatedModule,
      [[await testErc721.getAddress(), NftGatedType.ERC721, 0n, 1n, false]])
    const account = await user3.getAddress()
    expect(await assetHub.assetGated(assetId, account)).to.be.false
    await expect(testErc721.mint(await user3.getAddress(), 1n)).to.not.be.reverted
    expect(await assetHub.assetGated(assetId, account)).to.be.true
  })

  it("Test asset gated with ERC1155 gated module", async function () {
    const assetId = await ceateAssetWithGated(
      assetHub,
      nftGatedModule,
      [[await testErc1155.getAddress(), NftGatedType.ERC1155, 1n, 1n, false]])
    const account = await user3.getAddress()
    expect(await assetHub.assetGated(assetId, account)).to.be.false
    await expect(testErc1155.mint(await user3.getAddress(), 1, 1)).to.not.be.reverted
    expect(await assetHub.assetGated(assetId, account)).to.be.true
  })

  it("Test asset gated with ERC1155 gated module", async function () {
    const assetId = await ceateAssetWithGated(
      assetHub,
      nftGatedModule,
      [[await testErc1155.getAddress(), NftGatedType.ERC1155, 1n, 5n, false]])
    const account = await user3.getAddress()
    await expect(testErc1155.mint(account, 1, 1)).to.not.be.reverted
    expect(await assetHub.assetGated(assetId, account)).to.be.false
    await expect(testErc1155.mint(account, 1, 6)).to.not.be.reverted
    expect(await assetHub.assetGated(assetId, account)).to.be.true
  })

  it("Should revert when create asset with not support gated module contract type", async function () {
    expect(
      ceateAssetWithGated(
        assetHub,
        nftGatedModule,
        [[ZeroAddress, NftGatedType.ERC1155, 0n, 10n, false]]))
      .to.be.reverted
    expect(
      ceateAssetWithGated(
        assetHub,
        nftGatedModule,
        [[await testToken.getAddress(), NftGatedType.ERC1155, 0n, 10n, false]]))
      .to.be.reverted
    expect(
      ceateAssetWithGated(
        assetHub,
        nftGatedModule,
        [[await testToken.getAddress(), NftGatedType.ERC721, 0n, 10n, false]]))
      .to.be.reverted
    expect(
      ceateAssetWithGated(
        assetHub,
        nftGatedModule,
        [[await testToken.getAddress(), NftGatedType.ERC721, 0n, 10n, false]]))
      .to.be.reverted
    expect(
      ceateAssetWithGated(
        assetHub,
        nftGatedModule,
        [[await testToken.getAddress(), 999 as any, 0n, 10n, false]]))
      .to.be.reverted
  })
})