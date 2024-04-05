require("dotenv").config();
require("@nomicfoundation/hardhat-ethers");
require("@nomicfoundation/hardhat-verify");
require("@nomicfoundation/hardhat-chai-matchers");
require("@openzeppelin/hardhat-upgrades");
require("@typechain/hardhat");
require("hardhat-gas-reporter");
require("hardhat-abi-exporter");
require("solidity-coverage");
require("hardhat-contract-sizer");
require("hardhat-tracer");

// Importing tasks

const ethMainnetUrl = process.env.ETH_MAINNET_URL || "https://rpc.ankr.com/eth";
const accounts = [process.env.PRIVATE_KEY];

module.exports = {
  paths: {
    sources: "./contracts",
  },
  solidity: {
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999_999,
      },
      viaIR: true,
      evmVersion: "paris",
    },
  },
  defender: {
    apiKey: process.env.DEFENDER_API_KEY,
    apiSecret: process.env.DEFENDER_SECRET_KEY,
  },
  typechain: {
    outDir: "typechain",
    target: "ethers-v5",
  },
  networks: {
    hardhat: {
      initialBaseFeePerGas: 0,
      chainId: 31337,
      hardfork: "shanghai",
      forking: {
        url: process.env.ETH_MAINNET_URL || "https://rpc.ankr.com/eth",
        enabled: false,
      },
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    ethMain: {
      chainId: 1,
      url: ethMainnetUrl,
      accounts,
    },
    goerli: {
      chainId: 5,
      url: `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`,
      accounts,
    },
    sepolia: {
      chainId: 11155111,
      url: "https://eth-sepolia.g.alchemy.com/v2/xBDUN8ElzPK2lNlfmeNv4rdumoE-J8_l",
      accounts,
    },
    arbitrumSepolia: {
      chainId: 421614,
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      accounts,
    },
    arbitrum: {
      chainId: 42161,
      url: "https://arbitrum-mainnet.infura.io/v3/7545b5b3e68246a9915a84ca5b9b5c68",
      accounts,
    },
    blastTestnet: {
      chainId: 168587773,
      url: "https://rpc.ankr.com/blast_testnet_sepolia/52b75d96b0312930727e185eff5208721ce56a5cc8c52f422a3f4385cc3949c8",
      accounts,
    },
  },
  contractSizer: {
    alphaSort: true,
    runOnCompile: true,
    disambiguatePaths: false,
    strict: true,
    only: [],
    except: [],
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false,
    currency: "USD",
  },
  abiExporter: {
    path: "./abis",
    clear: true,
    flat: false,
    only: ["HeroPool", "HeroPoolFactory", "MyToken"],
    spacing: 2,
  },
  sourcify: {
    enabled: true,
    apiUrl: "https://sourcify.dev/server",
    browserUrl: "https://repo.sourcify.dev",
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY || "",
      goerli: "G1DNIIPHYADIDH87K98C2K593TSTYIJVVP",
      sepolia: process.env.ETHERSCAN_API_KEY || "",
      blastTestnet: "blastTestnet",
    },
    customChains: [
      {
        network: "blastTestnet",
        chainId: 168587773,
        urls: {
          apiURL: "https://api-sepolia.blastscan.io/api",
          browserURL: "https://sepolia.blastscan.io",
        },
      },
    ],
  },
};
