import { ethers } from "hardhat";
import { DebugTest, DebugTest__factory } from "../typechain-types"
import { Signer } from "ethers";
import { expect } from "chai";

describe("Debug Test", () => {
  let test: DebugTest;
  let deployer: Signer;

  before(async () => {
    const signers = await ethers.getSigners();
    deployer = signers[0];
    test = await new DebugTest__factory(deployer).deploy();
  })

  it("value", async () => {
    await expect(test.value()).to.be.not.reverted;
  })
})