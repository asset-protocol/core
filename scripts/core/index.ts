import { ethers, upgrades } from "hardhat";

export async function deployAssetHub() {
  console.log("Deploying contract: ", "AssetHub");
  const assetHub = await upgrades.deployProxy(await ethers.getContractFactory("AssetHub"), [], {
    kind: "uups"
  })
  await assetHub.waitForDeployment();
  console.log("AssetHub deployed to:", await assetHub.getAddress());
  return assetHub;
}