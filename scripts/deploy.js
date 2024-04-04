// deploy.js
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  const FactoryContract = await ethers.getContractFactory("FactoryContract");
  const factoryContract =
    await FactoryContract.deploy(/* pass constructor arguments here */);

  await factoryContract.deployed();

  console.log("FactoryContract address:", factoryContract.address);

  // Optionally, deploy CompetitionContract here
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
