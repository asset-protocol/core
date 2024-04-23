import { ethers, ignition } from 'hardhat';
import "@openzeppelin/hardhat-upgrades";
import { AssetHub, AssetHubLogic__factory, Events, TestERC1155, TestERC1155__factory, TestERC721, TestERC721__factory, TestToken, TestToken__factory, TokenGlobalModule, AssetHubLogic, LiteAssetHubManager, AssetHubCreatorNFT, Curation } from "../typechain-types";
import { Signer, ZeroAddress } from 'ethers';
import { expect } from 'chai';
import { AssetHubLibraryAddresses } from '../typechain-types/factories/contracts/AssetHub__factory';
import liteManagerModule from '../ignition/modules/deploy-lite-manager';
import { Contracts } from '../ignition/modules/core/contracts';
import { LiteHubInfoStruct } from '../typechain-types/contracts/management/LiteAssetHubManager';
import TestTokenModule from '../ignition/modules/core/TestToken';

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
export let assetHubLogic: AssetHubLogic;
export let eventsLib: Events;
export let hubManager: LiteAssetHubManager;
export let tokenGlobalModule: TokenGlobalModule;
export let creatorNFT: AssetHubCreatorNFT;
export let modules: LiteHubInfoStruct;
export let assetCuration: Curation;

export type DeployCtx = {
  assetHub: AssetHub
  tokenImpl: TestToken
}

export async function deployContracts(): Promise<DeployCtx> {
  const hubAddress = await hubManager.deploy.staticCall({
    name: "TestHUb",
    admin: deployerAddress,
    createModule: ZeroAddress
  })
  await hubManager.deploy({
    name: "TestHUb",
    admin: deployerAddress,
    createModule: ZeroAddress
  });
  const assetHub = await ethers.getContractAt("AssetHub", hubAddress, deployer);
  const { testToken } = await ignition.deploy(TestTokenModule);
  const tokenImpl = await ethers.getContractAt(Contracts.TestToken, testToken, deployer);
  return {
    assetHub,
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
  assetHubLogic = await new AssetHubLogic__factory(deployer).deploy()
  assethubLibs = {
    "contracts/base/AssetHubLogic.sol:AssetHubLogic": await assetHubLogic.getAddress()
  }
  const {
    liteManager,
    tokenGlobalModule: gm,
    creatorNFT: nft,
    oneFeeCollectModule,
    oneNftAssetGatedModule,
    oneTokenCollectModule,
    testToken: tkn,
    curation
  } = await ignition.deploy(liteManagerModule)
  hubManager = await ethers.getContractAt(Contracts.LiteAssetHubManager, liteManager);
  testToken = await ethers.getContractAt(Contracts.TestToken, tkn);
  tokenGlobalModule = await ethers.getContractAt(Contracts.TokenGlobalModule, gm);
  creatorNFT = await ethers.getContractAt(Contracts.AssetHubCreatorNFT, nft);
  assetCuration = await ethers.getContractAt(Contracts.Curation, curation);
  modules = {
    tokenCollectModule: await oneTokenCollectModule.getAddress(),
    feeCollectModule: await oneFeeCollectModule.getAddress(),
    nftGatedModule: await oneNftAssetGatedModule.getAddress(),
    createModule: ZeroAddress
  }
});


