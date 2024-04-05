// deploy.js
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const CampaignFactory = await ethers.getContractFactory("CampaignFactory");
  const campaignFactory =
    await CampaignFactory.deploy(/* pass constructor arguments here */);

  await campaignFactory.deployed();

  console.log("CampaignFactory address:", campaignFactory.address);

  // Optionally, deploy CompetitionContract here
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
