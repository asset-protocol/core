import { ZeroAddress } from "ethers";
import { deployer, deployerAddress, hubManager, user } from "../setup.spec";
import { expect } from "chai";
import { AssetHubCreatorNFT, AssetHubCreatorNFT__factory } from "../../typechain-types";

describe("Test deploy asset hub by hub creatorNFT", () => {
  let hubCreatorNFT: AssetHubCreatorNFT

  before(async () => {
    hubCreatorNFT = await new AssetHubCreatorNFT__factory(deployer).deploy();
    await expect(hubCreatorNFT.initialize("Test Creator NFT", "TB_NFT")).to.be.not.reverted;
    await expect(hubManager.setHubCreatorNFT(hubCreatorNFT)).to.be.not.reverted;
  })

  it("should be reverted when deploy a new assethub without  hub creator NFT", async function () {
    const args = {
      admin: deployerAddress,
      name: "TestHUB-creatorNFT",
      collectNft: true,
      createModule: ZeroAddress,
    }
    const userHubManager = hubManager.connect(user);
    await expect(userHubManager.deploy(args)).to.be.reverted;
  });

  it("should be reverted when deploy a new assethub with a hub creator NFT", async function () {
    const userAddr = await user.getAddress();
    await expect(hubCreatorNFT.airdrop([userAddr])).to.be.not.reverted;
    const args = {
      admin: deployerAddress,
      name: "TestHUB-creatorNFT-user",
      collectNft: true,
      createModule: ZeroAddress,
    }
    const userHubManager = hubManager.connect(user);
    await expect(userHubManager.deploy(args)).to.be.not.reverted;
  });
})