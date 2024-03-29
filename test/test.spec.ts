import { AbiCoder, ZeroAddress } from "ethers";
import { AssetHub__factory } from "../typechain-types";
import { expect } from "chai";
import { ZERO_DATA } from "./contants";
import { ethers } from 'hardhat';

describe("", async () => {
  it("test", async function () {
    const deployer = await ethers.getSigners()
    const ah = AssetHub__factory.connect("0xC2876F1d401aDe7041774AE81b3b272476e43eC0", deployer[0])
    await ah.collect(1, '0x');
  })
})