import { ethers, upgrades } from 'hardhat';
import "@openzeppelin/hardhat-upgrades";
import { AssetHub, AssetHub__factory, AssetHubLogic, AssetHubLogic__factory, CollectNFT, CollectNFT__factory, Events, Events__factory, TestERC1155, TestERC1155__factory, TestERC721, TestERC721__factory, TestToken, TestToken__factory, TokenTransfer__factory, UUPSUpgradeable, UUPSUpgradeable__factory } from "../typechain-types";
import { Signer, ZeroAddress } from 'ethers';
import { expect } from 'chai';
import { AssetHubLibraryAddresses } from '../typechain-types/factories/contracts/core/AssetHub__factory';

export let accounts: Signer[];
export let deployer: Signer;
export let user: Signer;
export let user3: Signer;
export let userAddress: string;
export let deployerAddress: string;
export let testToken: TestToken;
export let testErc721: TestERC721;
export let testErc1155: TestERC1155;
export let assethubLibs: AssetHubLibraryAddresses;
export let eventsLib: Events;

export type DeployCtx = {
  assetHub: AssetHub
  collectNFTImpl: CollectNFT
  tokenImpl: TestToken
}

export async function deployContracts(): Promise<DeployCtx> {
  const tokenImpl = await new TestToken__factory(deployer).deploy("EmptyToken", "ET")

  const assetHubImpl = new AssetHub__factory(assethubLibs, deployer)
  const assethubProxy = await upgrades.deployProxy(assetHubImpl, [], {
    kind: "uups",
    initializer: false,
    unsafeAllow: ["external-library-linking"],
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

  testErc721 = await new TestERC721__factory(deployer).deploy("TEST721", "T721")
  testErc1155 = await new TestERC1155__factory(deployer).deploy()
  testToken = await new TestToken__factory(deployer).deploy("TEST", "TST")
  const libAsset = await new AssetHubLogic__factory(deployer).deploy()
  assethubLibs = {
    "contracts/base/AssetHubLogic.sol:AssetHubLogic": await libAsset.getAddress()
  }
  // Event library deployment is only needed for testing and is not reproduced in the live environment
  eventsLib = await new Events__factory(deployer).deploy();
});


