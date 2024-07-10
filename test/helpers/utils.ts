import { hexlify, keccak256 } from "ethers";

// export function computeContractAddress(deployerAddress: string, nonce: number): string {
//   const hexNonce = hexlify(nonce);
//   return '0x' + keccak256(RLP.encode([deployerAddress, hexNonce])).substr(26);
// }