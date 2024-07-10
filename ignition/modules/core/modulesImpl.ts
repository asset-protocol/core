import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { Contracts } from "./contracts";
import { ContractFuture } from "@nomicfoundation/ignition-core";

export const AssetHubImplModule = buildModule(Contracts.AssetHub, m => {
  const assetHubImpl = m.contract(Contracts.AssetHub, [], {
    id: Contracts.AssetHub + "impl",
    libraries: {
      "AssetHubLogic": m.library(Contracts.AssetHubLogic)
    }
  })
  return { assetHubImpl }
});

export const CollectNFTImplModule = (manager: ContractFuture<string>) => {
  return buildModule(Contracts.CollectNFT, (m) => {
    const collectNFTImpl = m.contract(Contracts.CollectNFT, []);
    return { collectNFTImpl };
  });
}

export const TokenCollectModule = (manager: ContractFuture<string>) => {
  return buildModule(Contracts.TokenCollectModule, (m) => {
    const impl = m.contract(Contracts.TokenCollectModule, [], {
      id: Contracts.TokenCollectModule + "_impl"
    });
    const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
    const tokenCollectModule = m.contractAt(Contracts.TokenCollectModule, proxy);
    m.call(tokenCollectModule, "initialize", [manager]);
    return { tokenCollectModule };
  });
}

export const FeeCollectModule = (manager: ContractFuture<string>) => {
  return buildModule(Contracts.FeeCollectModule, (m) => {
    const impl = m.contract(Contracts.FeeCollectModule, [], {
      id: Contracts.FeeCollectModule + "_impl"
    });
    const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
    const feeCollectModule = m.contractAt(Contracts.FeeCollectModule, proxy);
    m.call(feeCollectModule, "initialize", [manager]);
    return { feeCollectModule };
  });
}

export const NftAssetGatedModule = (manager: ContractFuture<string>) => {
  return buildModule(Contracts.NftAssetGatedModule, (m) => {
    const impl = m.contract(Contracts.NftAssetGatedModule, [], {
      id: Contracts.NftAssetGatedModule + "_impl"
    });
    const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
    const nftAssetGatedModule = m.contractAt(Contracts.NftAssetGatedModule, proxy);
    m.call(nftAssetGatedModule, "initialize", [manager]);
    return { nftAssetGatedModule };
  });
}