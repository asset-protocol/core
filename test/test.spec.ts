import { AbiCoder, ZeroAddress } from "ethers";
import { AssetHub__factory } from "../typechain-types";
import { expect } from "chai";
import { ZERO_DATA } from "./contants";
import { ethers } from 'hardhat';

describe("", async () => {
  it("test", async function () {
    const deployer = await ethers.getSigners()
    const ah = AssetHub__factory.connect("0xC20f603Bc1D0B558CA3a0880EEa3B733FC15b85d", deployer[0])
    const initData = AbiCoder.defaultAbiCoder().encode(
      ["address", "address", "uint256"],
      ["0xc2ADF187D9B064F68FcD8183195cddDB33E10E8F", "0x4845Af017fc4A19B0D053806B7288bB269de05b3", 10]
    )
    await expect(ah.update(2, {
      contentURI: "https://www.baidu.com",
      collectModule: "0x7E08f2E743d0Bd9B19A588f0C7B5EE32d24F51d0",
      collectModuleInitData: initData,
      gatedModule: ZeroAddress,
      gatedModuleInitData: ZERO_DATA,
    })).to.not.be.reverted;
  })
})