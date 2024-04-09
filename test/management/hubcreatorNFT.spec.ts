import { ethers, upgrades } from "hardhat";
import { AssetHubCreatorNFT } from "../../typechain-types";
import { deployerAddress, user, userAddress } from "../setup.spec";
import { expect } from "chai";

describe("Test assethub creator NFT contract", () => {
  let hubCreatorNFT: AssetHubCreatorNFT
  
  before(async () => {
    const fc = await ethers.getContractFactory("AssetHubCreatorNFT");
    const proxy = await upgrades.deployProxy(fc, [], {
      kind: "uups",
      initializer: false,
    });
    hubCreatorNFT = await ethers.getContractAt("AssetHubCreatorNFT", proxy);
    await expect(hubCreatorNFT.initialize("Test Hub Creator NFT", "THC_NFT")).to.be.not.reverted;
  })

  it("Set a whitelist", async () => {
    await expect(hubCreatorNFT.setWhitelist(userAddress, true)).to.be.not.reverted;
    expect(await hubCreatorNFT.whitelisted(userAddress)).to.be.true;
  })

  it("Set batch whitelist", async () => {
    const addresses = [deployerAddress, userAddress];
    const res = [true, false];
    await expect(hubCreatorNFT.setWhitelistBatch(addresses, res)).to.be.not.reverted;
    expect(await hubCreatorNFT.whitelisted(deployerAddress)).to.be.true;
    expect(await hubCreatorNFT.whitelisted(userAddress)).to.be.false;
  })

  it("Should be revert when mint with wallet address not in whitelist", async () => {
    const userCtract = hubCreatorNFT.connect(user);
    await expect(userCtract.mint()).to.be.reverted;
  })

  it("Only owner can set whitelist", async () => {
    const userCtract = hubCreatorNFT.connect(user);
    await expect(userCtract.setWhitelist(userAddress, true)).to.be.reverted;
    const addresses = [deployerAddress, userAddress];
    const res = [true, false];
    await expect(userCtract.setWhitelistBatch(addresses, res)).to.be.reverted;

  })

  it("Should be mint when wallet address in whitelist", async () => {
    const userCtract = hubCreatorNFT.connect(user);
    await expect(hubCreatorNFT.setWhitelist(userAddress, true)).to.be.not.reverted;
    await expect(userCtract.mint()).to.be.not.reverted;
  })

  it("Only owner can airdrop", async () => {
    const userCtract = hubCreatorNFT.connect(user);
    await expect(userCtract.airdrop([userAddress])).to.be.reverted;
  })

  it("Owner can airdrop", async () => {
    await expect(hubCreatorNFT.airdrop([userAddress])).to.be.not.reverted;
  })
})