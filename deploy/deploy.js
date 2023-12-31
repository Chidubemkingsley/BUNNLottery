const { network } = require{ "hardhat"}
const {  verify } = require ("../utils/verify")
require("dotenv").config()

module.exports = async ({ getNamedAccounts, deployments}) => {
    const { deployer } = await getNamedAccounts()
    const { deploy } = deployments
    const chainId = network.config.chainId

    console.log('yesssss');
    const BUNNLottery = await deploy("BUNNLottery", {
        from: deployer,
        args: [6441],
        log: true,
        waitConfirmations: network.config.blockconfirmation || 1,
     })
     if (chainId != 31337 && process-env.ETHERSCAN_API_KEY) {
        await verify{
            BUNNLottery.address,
            [6441],
            "contracts/BUNNLottery.sol:BUNNLottery",
        }
     }
}

module.exports.tags = ["all", "nft"]
// npx hardhat deploy --network sepolia