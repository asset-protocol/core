import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter"
import "@nomicfoundation/hardhat-ignition-ethers";
import '@openzeppelin/hardhat-upgrades';
import { ProxyAgent, setGlobalDispatcher } from "undici"
import dotenv from 'dotenv'

dotenv.config({
  path: [".env", ".env.test"]
})

const proxyURL = vars.get("PROXY_URL", undefined)
if (proxyURL) {
  const proxyAgent = new ProxyAgent(proxyURL)
  setGlobalDispatcher(proxyAgent)
}

const DEPLOYER_PRIVATEKEY = vars.get("DEPLOYER_PRIVATEKEY")
const APIKEY_polygonMumbai = vars.get("APIKEY_polygonMumbai", "")

const OPSepolia_RPC = vars.get("OPSEPOLIA_RPC", "")
const APIKEY_opSepolia = vars.get("APIKEY_opSepolia")

const NETWORK = vars.get("DEFAULT_NETWORK", "hardhat")

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  defaultNetwork: NETWORK,
  networks: {
    hardhat: {},
    "polygonMumbai": {
      url: "https://rpc-mumbai.polygon.technology",
      accounts: [DEPLOYER_PRIVATEKEY]
    },
    "opSepolia": {
      url: OPSepolia_RPC,
      accounts: [DEPLOYER_PRIVATEKEY]
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: APIKEY_polygonMumbai,
      opSepolia: APIKEY_opSepolia
    },
    customChains: [
      {
        network: "opSepolia",
        chainId: 11155420,
        urls: {
          apiURL: "https://api-sepolia-optimism.etherscan.io/api",
          browserURL: "https://sepolia-optimism.etherscan.io/"
        }
      }
    ]
  },
  abiExporter: {
    path: './abi',
    runOnCompile: true,
    flat: true,
    pretty: true,
    only: ['AssetHub', "IContractMetadata", "FeeCollectModule", "NftAssetGatedModule"],
    spacing: 2,
  },
};

export default config;
