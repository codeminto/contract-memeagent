// import { config as dotEnvConfig } from "dotenv";
// dotEnvConfig();
// import { task, vars } from "hardhat/config";
// import { HardhatUserConfig } from "hardhat/types";

import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-verify";
import "@nomicfoundation/hardhat-chai-matchers";
import "@openzeppelin/hardhat-upgrades";
import "@typechain/hardhat";

import "hardhat-gas-reporter";
import "hardhat-abi-exporter";
import "solidity-coverage";
import "hardhat-contract-sizer";

require("./tasks/index.js");

const ethMainnetUrl = vars.get("ETH_MAINNET_URL", "https://rpc.ankr.com/eth");
const accounts = [vars.get("PRIVATE_KEY", process.env.PRIVATE_KEY)];

task("accounts", "Prints the list of accounts", async (_, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("evm", "Prints the configured EVM version", async (_, hre) => {
  console.log(hre.config.solidity.compilers[0].settings.evmVersion);
});

task(
  "balances",
  "Prints the list of accounts and their balances",
  async (_, hre) => {
    const accounts = await hre.ethers.getSigners();

    for (const account of accounts) {
      console.log(
        account.address +
          " " +
          (await hre.ethers.provider.getBalance(account.address))
      );
    }
  }
);

const config = {
  paths: {
    sources: "./contracts",
  },
  solidity: {
    // Only use Solidity default versions `>=0.8.20` for EVM networks that support the opcode `PUSH0`
    // Otherwise, use the versions `<=0.8.19`
    version: "0.8.23",
    settings: {
      optimizer: {
        enabled: true,
        runs: 999_999,
      },
      viaIR: true,
      evmVersion: "paris", // Prevent using the `PUSH0` opcode
    },
  },
  defender: {
    apiKey: "AAYvJPpkLxgNhSfNAUWFriDuXRTTMMUY" || process.env.DEFENDER_API_KEY,
    apiSecret:
      "4f2ccVqJX7zZg5uZehMNW8GtmgtpkCLAFGSRgRZyfpmbLP5S4LWrLCVJX1XqZnD7" ||
      process.env.DEFENDER_SECRET_KEY,
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
        url: vars.get("ETH_MAINNET_URL", ethMainnetUrl),
        // The Hardhat network will by default fork from the latest mainnet block
        // To pin the block number, specify it below
        // You will need access to a node with archival data for this to work!
        // blockNumber: 14743877,
        // If you want to do some forking, set `enabled` to true
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
      url: vars.get(
        "ETH_GOERLI_TESTNET_URL",
        `https://eth-goerli.g.alchemy.com/v2/${process.env.ALCHEMY_KEY}`
      ),
      accounts,
    },
    sepolia: {
      chainId: 11155111,
      url: vars.get(
        "ETH_SEPOLIA_TESTNET_URL",
        "https://eth-sepolia.g.alchemy.com/v2/xBDUN8ElzPK2lNlfmeNv4rdumoE-J8_l"
      ),
      accounts,
    },
    arbitrumSepolia: {
      chainId: 421614,
      url: "https://sepolia-rollup.arbitrum.io/rpc",
      accounts,
    },
    arbitrum: {
      chainId: 42161,
      url: `https://arbitrum-mainnet.infura.io/v3/7545b5b3e68246a9915a84ca5b9b5c68`,
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
    enabled: vars.has("REPORT_GAS") ? true : false,
    currency: "USD",
  },
  abiExporter: {
    path: "./abis",
    clear: true,
    flat: false,
    only: ["KolRegistry", "MyToken", "SaleNFT", "HeroGinNft", "HeroGinNftX"],
    spacing: 2,
  },
  sourcify: {
    // Enable Sourcify verification by default
    enabled: true,
    apiUrl: "https://sourcify.dev/server",
    browserUrl: "https://repo.sourcify.dev",
  },
  etherscan: {
    // Add your own API key by getting an account at etherscan (https://etherscan.io), snowtrace (https://snowtrace.io) etc.
    // This is used for verification purposes when you want to `npx hardhat verify` your contract using Hardhat
    // The same API key works usually for both testnet and mainnet
    apiKey: {
      // For Ethereum testnets & mainnet
      mainnet: vars.get("ETHERSCAN_API_KEY", ""),
      goerli: "G1DNIIPHYADIDH87K98C2K593TSTYIJVVP",
      sepolia: "G3JBP7XPHRGRJGRTZ6ZPZ85K1ZXTNB7SX6",
      blastTestnet: "blastTestnet",
    },
    customChains: [
      // {
      //   network: "blastTestnet",
      //   chainId: 168587773,
      //   urls: {
      //     apiURL:
      //       "https://api.routescan.io/v2/network/testnet/evm/168587773/etherscan",
      //     browserURL: "https://testnet.blastscan.io",
      //   },
      // },
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
export default config;
