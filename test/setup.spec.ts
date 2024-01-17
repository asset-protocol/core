import { ethers } from 'hardhat';
import { AssetHub, AssetHub__factory, SubscribeNFT, SubscribeNFT__factory, UpgradeableProxy, UpgradeableProxy__factory } from "../typechain-types";
import { Signer } from 'ethers';
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
}

export async function deployContracts(): Promise<DeployCtx> {
  const assetHubImpl = await new AssetHub__factory(deployer).deploy("AssetHub_TEST", "AHT", deployerAddress)
  const subscribeNFTImpl = await new SubscribeNFT__factory(deployer).deploy(await assetHubImpl.getAddress())
  let admin = AssetHub__factory.connect(await assetHubImpl.getAddress(), deployer)
  await admin.setSubscribeNFTImpl(await subscribeNFTImpl.getAddress())
  const hubProxy = await new UpgradeableProxy__factory(deployer).deploy(await assetHubImpl.getAddress(), deployerAddress, "0x")
  return {
    assetHubImpl,
    hubProxy,
    subscribeNFTImpl,
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


