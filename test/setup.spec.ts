import { ethers, upgrades } from 'hardhat';
import "@openzeppelin/hardhat-upgrades";
import { AssetHub, AssetHub__factory, CollectNFT, CollectNFT__factory, TestToken, TestToken__factory, TokenTransfer__factory, UUPSUpgradeable, UUPSUpgradeable__factory } from "../typechain-types";
import { Signer, ZeroAddress } from 'ethers';
import { expect } from 'chai';

export let accounts: Signer[];
export let deployer: Signer;
export let user: Signer;
export let user3: Signer;
export let userAddress: string;
export let deployerAddress: string;

export type DeployCtx = {
  assetHub: AssetHub
  collectNFTImpl: CollectNFT
  tokenImpl: TestToken
}

export async function deployContracts(): Promise<DeployCtx> {
  const tokenImpl = await new TestToken__factory(deployer).deploy("EmptyToken", "ET")

  const assetHubImpl = await ethers.getContractFactory("AssetHub")

  const assethubProxy = await upgrades.deployProxy(assetHubImpl, [], {
    kind: "uups",
    initializer: false,
  })

  await assethubProxy.waitForDeployment()

  const collectNFTImpl = await new CollectNFT__factory(deployer).deploy(await assethubProxy.getAddress())
  assethubProxy.initialize("AssetHub_TEST", "AHT", await deployer.getAddress(), await collectNFTImpl.getAddress(), ZeroAddress)
  const assetHub = await ethers.getContractAt("AssetHub", assethubProxy, deployer)
  return {
    assetHub,
    collectNFTImpl,
    tokenImpl,
  }
}

before(async function () {
  accounts = await ethers.getSigners();
  deployer = accounts[0];
  user = accounts[1];
  user3 = accounts[2];
  deployerAddress = await deployer.getAddress()
  userAddress = await user.getAddress()

  it("user address", async function () {
    expect(user).to.not.be.undefined
  })

});


