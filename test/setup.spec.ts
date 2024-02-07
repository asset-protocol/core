import { ethers } from 'hardhat';
import { AssetHub, AssetHub__factory, SubscribeNFT, SubscribeNFT__factory, TokenTransfer__factory, UpgradeableProxy, UpgradeableProxy__factory } from "../typechain-types";
import { Signer, ZeroAddress } from 'ethers';
import { expect } from 'chai';

export let accounts: Signer[];
export let deployer: Signer;
export let user: Signer;
export let userAddress: string;
export let deployerAddress: string;

export type DeployCtx = {
  assetHubImpl: AssetHub
  hubProxy: UpgradeableProxy
  subscribeNFTImpl: SubscribeNFT
  tokenImpl: Edu3ScoreToken
}

export async function deployContracts(): Promise<DeployCtx> {
  const tokenImpl = await new Tes(deployer).deploy("EmptyToken", "ET")
  await tokenImpl.transfer(userAddress, 10000)
  await tokenImpl.transfer(deployerAddress, 10000)

  const assetHubImpl = await new AssetHub__factory(deployer).deploy("AssetHub_TEST", "AHT", await deployer.getAddress())
  const tt = await new TokenTransfer__factory(deployer).deploy(await assetHubImpl.getAddress())
  await tokenImpl.transfer(await tt.getAddress(), 10000)
  await tokenImpl.connect(user).approve(await tt.getAddress(), 10000)
  await tokenImpl.connect(deployer).approve(await tt.getAddress(), 10000)

  const subscribeNFTImpl = await new SubscribeNFT__factory(deployer).deploy(await assetHubImpl.getAddress())
  assetHubImpl.initialize(await subscribeNFTImpl.getAddress(), await tt.getAddress(), await tokenImpl.getAddress())
  const hubProxy = await new UpgradeableProxy__factory(deployer).deploy(await assetHubImpl.getAddress(), deployerAddress, "0x")
  return {
    assetHubImpl,
    hubProxy,
    subscribeNFTImpl,
    tokenImpl,
  }
}

before(async function () {
  accounts = await ethers.getSigners();
  deployer = accounts[0];
  user = accounts[1];
  deployerAddress = await deployer.getAddress()
  userAddress = await user.getAddress()

  it("user address", async function () {
    expect(user).to.not.be.undefined
  })

});


