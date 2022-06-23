require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.4",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chanId: 1337,
    },
    bsc: {
      url: "https://bsc-dataseed.binance.org/",
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },
    bscTestnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },
    ropsten: {
      url: "https://ropsten.infura.io/v3/" + process.env.INFURA_SECRET_KEY,
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },
    ropstenAlch: {
      url: "https://eth-ropsten.alchemyapi.io/v2/" + process.env.ALCHEMY_SECRET_KEY,
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },
    mumbai: {
      url: "https://polygon-mumbai.g.alchemy.com/v2/" + process.env.ALCHEMY_SECRET_KEY,
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },
  },
};
