import { AssetHub } from "../../typechain-types"
import { ZERO_DATA } from "../contants"
import { AbiCoder, AddressLike, BytesLike, ZeroAddress } from "ethers"

export function createAsset(hub: AssetHub, collectModule: AddressLike, collectInitData: BytesLike) {
  return hub.create({
    publisher: ZeroAddress,
    contentURI: "https://www.google.com",
    collectModule: collectModule,
    collectModuleInitData: collectInitData,
    assetCreateModuleData: ZERO_DATA,
    gatedModule: ZeroAddress,
    gatedModuleInitData: ZERO_DATA,
  })
}

export function createAssetStatic(hub: AssetHub, module: AddressLike, initData: BytesLike) {
  return hub.create.staticCall({
    publisher: ZeroAddress,
    contentURI: "https://www.google.com",
    collectModule: module,
    collectModuleInitData: initData,
    assetCreateModuleData: ZERO_DATA,
    gatedModule: ZeroAddress,
    gatedModuleInitData: ZERO_DATA,
  })
}
