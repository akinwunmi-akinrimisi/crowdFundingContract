// import { ethers } from 'hardhat';
import pkg from 'hardhat';
const { ethers } = pkg;

async function main() {

    const Crowdfunding = await ethers.deployContract('Crowdfunding');

    await Crowdfunding.waitForDeployment();

    console.log('Crowdfunding Contract Deployed at ' + Crowdfunding.target);
}

// this pattern is recommended to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});