const hre = require('hardhat')

async function main() {
    // Get the contract
    const GenzyContract = await hre.ethers.getContractFactory('GENZY_PRESALE')

    // Deploy the contract
    const genzyContract = await GenzyContract.deploy()

    // Wait for the contract to be deployed
    await genzyContract.deployed()

    console.log('Contract deployed at address:', genzyContract.address)
}

// Run the script
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })