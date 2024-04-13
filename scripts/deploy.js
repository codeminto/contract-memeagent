// deploy.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const CampaignFactory = await ethers.getContractFactory("CampaignFactory");
  const campaignFactory = await CampaignFactory.deploy();
  console.log("CampaignFactory address:", campaignFactory.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
