import { ethers, upgrades } from 'hardhat';
import "@openzeppelin/hardhat-upgrades";
import { AssetHub, AssetHubFactory__factory, AssetHubLogic__factory, AssetHubManager, AssetHubManager__factory, CollectNFTFactory__factory, Events, Events__factory, TokenCollectModuleFactory__factory, TokenAssetCreateModuleFactory__factory, NftAssetGatedModuleFactory__factory, TestERC1155, TestERC1155__factory, TestERC721, TestERC721__factory, TestToken, TestToken__factory, FeeCollectModuleFactory__factory, TokenGlobalModuleFactory__factory, TokenGlobalModule, TokenGlobalModule__factory } from "../typechain-types";
import { AbiCoder, Signer, ZeroAddress, dataSlice } from 'ethers';
import { expect } from 'chai';
import { AssetHubLibraryAddresses } from '../typechain-types/factories/contracts/AssetHub__factory';

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
export let hubManager: AssetHubManager;
export let tokenGlobalModule: TokenGlobalModule;

export type DeployCtx = {
  assetHub: AssetHub
  tokenCollectModule: string
  tokenImpl: TestToken
}

export async function deployContracts(): Promise<DeployCtx> {
  const tokenImpl = await new TestToken__factory(deployer).deploy("EmptyToken", "ET")
  const hubAddress = await hubManager.deploy.staticCall({
    name: "TestHUb",
    admin: deployerAddress,
    collectNft: true,
    assetCreateModule: ZeroAddress
  })
  const res = await hubManager.deploy({
    name: "TestHUb",
    admin: deployerAddress,
    collectNft: true,
    assetCreateModule: ZeroAddress
  });
  const tx = await res.wait();
  const event = tx?.logs.find(l => l.topics[0] === hubManager.interface.getEvent("AssetHubDeployed").topicHash)
  expect(event).to.not.be.undefined
  const eventdata = AssetHubManager__factory.createInterface().decodeEventLog("AssetHubDeployed", event!.data)
  const assetHub = await ethers.getContractAt("AssetHub", hubAddress, deployer);
  return {
    assetHub,
    tokenImpl,
    tokenCollectModule: eventdata[3][3]
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

  const assetHubFactory = await new AssetHubFactory__factory(assethubLibs, deployer).deploy();
  const tokenCollectModuleFactory = await new TokenCollectModuleFactory__factory(deployer).deploy();
  const feeeAssetCollectModuleFactory = await new FeeCollectModuleFactory__factory(deployer).deploy();
  const nftGatedModuleFactory = await new NftAssetGatedModuleFactory__factory(deployer).deploy();
  const tokenAssetCreateModuleFactory = await new TokenAssetCreateModuleFactory__factory(deployer).deploy();
  const collectNFTFactory = await new CollectNFTFactory__factory(deployer).deploy();
  const tokenGlobalModuleFactory = await new TokenGlobalModuleFactory__factory(deployer).deploy();
  const factory = new AssetHubManager__factory(deployer);
  const hubManagerProxy = await upgrades.deployProxy(factory, [], {
    kind: "uups",
    initializer: false,
    unsafeAllow: ["external-library-linking"],
  })
  hubManager = await ethers.getContractAt("AssetHubManager", hubManagerProxy);
  const tx = await hubManager.initialize({
    assetHubFactory: await assetHubFactory.getAddress(),
    tokenCollectModuleFactory: await tokenCollectModuleFactory.getAddress(),
    nftGatedModuleFactory: await nftGatedModuleFactory.getAddress(),
    tokenAssetCreateModuleFactory: await tokenAssetCreateModuleFactory.getAddress(),
    collectNFTFactory: await collectNFTFactory.getAddress(),
    feeCollectModuleFactory: await feeeAssetCollectModuleFactory.getAddress()
  }, await tokenGlobalModuleFactory.getAddress());
  const res = await tx.wait();
  const instance = AssetHubManager__factory.createInterface();
  const eventLog = res?.logs.find(l => l.topics[0] === instance.getEvent("GlobalModuleChanged").topicHash);
  const log = instance.decodeEventLog("GlobalModuleChanged", eventLog!.data);
  tokenGlobalModule = TokenGlobalModule__factory.connect(log[0], deployer);
  await expect(tokenGlobalModule.setRecipient(deployerAddress)).to.not.be.reverted;
  await expect(tokenGlobalModule.setToken(await testToken.getAddress())).to.not.be.reverted;
  await expect(tokenGlobalModule.setDefaultConfig({
    collectFee: 0,
    updateFee: 0,
    createFee: 0
  })).to.not.be.reverted;
});


