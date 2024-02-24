import { ContractFactory } from "ethers";

export async function deployContract<T extends ContractFactory>(factory: T, args: Parameters<T["deploy"]>) {
  console.log("Deploying contract: ", typeof factory);
  const contract = await factory.deploy(...args);
  return contract;
}