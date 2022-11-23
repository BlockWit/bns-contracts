const PaymentReceiver = artifacts.require('PaymentReceiver');
const { logger } = require('../util');

async function deploy () {
  const { log, logAddress } = logger(config.network);
  const [deployer] = await web3.eth.getAccounts();

  const paymentReceiver = await PaymentReceiver.new({ from: deployer });
  log(`PaymentProcessor deployed: @address{${paymentReceiver.address}}`);
  logAddress('Test', paymentReceiver.address);

}

module.exports = async function main (callback) {
  try {
    await deploy();
    console.log('success');
    callback(null);
  } catch (e) {
    console.log('error');
    console.log(e);
    callback(e);
  }
};
