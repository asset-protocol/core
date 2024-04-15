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

export const OneCollectNFTImplModule = (manager: ContractFuture<string>) => {
  return buildModule(Contracts.OneCollectNFT, (m) => {
    const oneCollectNFTImpl = m.contract(Contracts.OneCollectNFT, []);
    return { oneCollectNFTImpl };
  });
}

export const OneTokenCollectModule = (manager: ContractFuture<string>) => {
  return buildModule(Contracts.OneTokenCollectModule, (m) => {
    const impl = m.contract(Contracts.OneTokenCollectModule, [], {
      id: Contracts.OneTokenCollectModule + "_impl"
    });
    const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
    const oneTokenCollectModule = m.contractAt(Contracts.OneTokenCollectModule, proxy);
    m.call(oneTokenCollectModule, "initialize", [manager]);
    return { oneTokenCollectModule };
  });
}

export const OneFeeCollectModule = (manager: ContractFuture<string>) => {
  return buildModule(Contracts.OneFeeCollectModule, (m) => {
    const impl = m.contract(Contracts.OneFeeCollectModule, [], {
      id: Contracts.OneFeeCollectModule + "_impl"
    });
    const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
    const oneFeeCollectModule = m.contractAt(Contracts.OneFeeCollectModule, proxy);
    m.call(oneFeeCollectModule, "initialize", [manager]);
    return { oneFeeCollectModule };
  });
}

export const OneNftAssetGatedModule = (manager: ContractFuture<string>) => {
  return buildModule(Contracts.OneNftAssetGatedModule, (m) => {
    const impl = m.contract(Contracts.OneNftAssetGatedModule, [], {
      id: Contracts.OneNftAssetGatedModule + "_impl"
    });
    const proxy = m.contract(Contracts.UpgradeableProxy, [impl, '0x']);
    const oneNftAssetGatedModule = m.contractAt(Contracts.OneNftAssetGatedModule, proxy);
    m.call(oneNftAssetGatedModule, "initialize", [manager]);
    return { oneNftAssetGatedModule };
  });
}