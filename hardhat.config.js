require('@nomiclabs/hardhat-ethers')
require('@openzeppelin/hardhat-upgrades')
require('@nomiclabs/hardhat-etherscan')
require('dotenv').config()

const { PRIVATE_KEY, ETHERSCAN_API, ALCHEMY_KEY } = process.env

module.exports = {
  solidity: '0.8.26', // Specify the Solidity version
  etherscan: {
    apiKey: ETHERSCAN_API
  },
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545', // Localhost network configuration
    },
    eth: {
      url: `https://eth-mainnet.g.alchemy.com/v2/${ ALCHEMY_KEY }`, // ETH mainnet network configuration with Alchemy
      accounts: [`0x${ PRIVATE_KEY }`],
    },
  },
}