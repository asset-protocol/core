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

const proxyURL = vars.get("PROXY_URL", "")
if (proxyURL) {
  const proxyAgent = new ProxyAgent(proxyURL)
  setGlobalDispatcher(proxyAgent)
}

const DEPLOYER_PRIVATEKEY = vars.get("DEPLOYER_PRIVATEKEY", "")
const APIKEY_polygonMumbai = vars.get("APIKEY_POLYGON_MUMBAI", "")

const OPSepolia_RPC = vars.get("OPSEPOLIA_RPC", "")
const APIKEY_baseSepolia = vars.get("APIKEY_BASE_SEPOLIA", "")
const APIKEY_polygonAmoy = vars.get("APIKEY_POLYGON_AMOY", "")

const NETWORK = vars.get("DEFAULT_NETWORK", "hardhat")

const config: HardhatUserConfig = {
  solidity: "0.8.20",
  defaultNetwork: NETWORK,
  networks: {
    hardhat: {},
    "polygonAmoy": {
      url: "https://rpc-amoy.polygon.technology",
      accounts: [DEPLOYER_PRIVATEKEY]
    },
    "polygonMumbai": {
      url: "https://rpc-mumbai.polygon.technology",
      accounts: [DEPLOYER_PRIVATEKEY]
    },
    "baseSepolia": {
      url: "https://sepolia.base.org",
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
      baseSepolia: APIKEY_baseSepolia,
      polygonAmoy: APIKEY_polygonAmoy
    },
    customChains: [
      {
        network: "baseSepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.basescan.org/"
        }
      },
      {
        network: "polygonAmoy",
        chainId: 80002,
        urls: {
          apiURL: "https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/AMOY_TESTNET",
          browserURL: "https://www.oklink.com/amoy"
        }
      }
    ]
  },
  abiExporter: {
    path: './abi',
    runOnCompile: true,
    flat: true,
    only: ['AssetHub', "TokenGlobalModule", "Curation", "IERC20", "IContractMetadata", "TokenCollectModule", "NftAssetGatedModule"],
    spacing: 2,
  },
};

export default config;
